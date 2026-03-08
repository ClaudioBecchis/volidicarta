import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/review.dart';
import '../models/wishlist_book.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._();
  static Database? _db;

  DbHelper._();
  factory DbHelper() => _instance;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'volidicarta.db');
    return openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createWishlist(db);
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        book_title TEXT NOT NULL,
        book_author TEXT NOT NULL,
        book_cover_url TEXT,
        book_publisher TEXT,
        book_year TEXT,
        book_genre TEXT,
        rating INTEGER NOT NULL,
        review_title TEXT,
        review_body TEXT,
        start_date TEXT,
        end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, book_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // v3: migrazione completa (user_id → TEXT UUID)
      await db.execute('DROP TABLE IF EXISTS reviews');
      await db.execute('DROP TABLE IF EXISTS users');
      await _onCreate(db, newVersion);
      return; // reset completo, le versioni successive sono incluse
    }
    if (oldVersion < 4) {
      // v4: aggiunti start_date e end_date
      await db.execute('ALTER TABLE reviews ADD COLUMN start_date TEXT');
      await db.execute('ALTER TABLE reviews ADD COLUMN end_date TEXT');
    }
    if (oldVersion < 5) {
      // v5: nuova tabella wishlist
      await _createWishlist(db);
    }
  }

  Future<void> _createWishlist(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        book_title TEXT NOT NULL,
        book_author TEXT NOT NULL,
        book_cover_url TEXT,
        book_publisher TEXT,
        book_year TEXT,
        book_genre TEXT,
        notes TEXT,
        added_at TEXT NOT NULL,
        UNIQUE(user_id, book_id)
      )
    ''');
  }

  // --- Reviews ---

  Future<int> insertReview(Review review) async {
    final db = await database;
    return db.insert('reviews', review.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateReview(Review review) async {
    final db = await database;
    return db.update('reviews', review.toMap(),
        where: 'id = ?', whereArgs: [review.id]);
  }

  Future<int> deleteReview(int id) async {
    final db = await database;
    return db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    final db = await database;
    final res = await db.query('reviews',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC');
    return res.map(Review.fromMap).toList();
  }

  Future<Review?> getReviewForBook(String userId, String bookId) async {
    final db = await database;
    final res = await db.query('reviews',
        where: 'user_id = ? AND book_id = ?', whereArgs: [userId, bookId]);
    if (res.isEmpty) return null;
    return Review.fromMap(res.first);
  }

  Future<List<Review>> searchReviews(String userId, String query) async {
    final db = await database;
    final q = '%$query%';
    final res = await db.query(
      'reviews',
      where:
          'user_id = ? AND (book_title LIKE ? OR book_author LIKE ? OR review_title LIKE ? OR review_body LIKE ?)',
      whereArgs: [userId, q, q, q, q],
      orderBy: 'updated_at DESC',
    );
    return res.map(Review.fromMap).toList();
  }

  Future<Map<String, dynamic>> getStats(String userId) async {
    final db = await database;
    final total = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM reviews WHERE user_id = ?', [userId])) ??
        0;
    final avgRow = await db.rawQuery(
        'SELECT AVG(rating) as avg FROM reviews WHERE user_id = ?', [userId]);
    final avgRaw = avgRow.first['avg'];
    final avg = avgRaw != null ? (avgRaw as num).toDouble() : null;
    final dist = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      dist[i] = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT COUNT(*) FROM reviews WHERE user_id = ? AND rating = ?',
              [userId, i])) ??
          0;
    }
    return {'total': total, 'avg': avg, 'distribution': dist};
  }

  // --- Wishlist ---

  Future<int> addToWishlist(WishlistBook book) async {
    final db = await database;
    return db.insert('wishlist', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeFromWishlist(String userId, String bookId) async {
    final db = await database;
    return db.delete('wishlist',
        where: 'user_id = ? AND book_id = ?', whereArgs: [userId, bookId]);
  }

  Future<List<WishlistBook>> getWishlist(String userId) async {
    final db = await database;
    final res = await db.query('wishlist',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'added_at DESC');
    return res.map(WishlistBook.fromMap).toList();
  }

  Future<bool> isInWishlist(String userId, String bookId) async {
    final db = await database;
    final res = await db.query('wishlist',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        limit: 1);
    return res.isNotEmpty;
  }

  Future<int> wishlistCount(String userId) async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM wishlist WHERE user_id = ?', [userId])) ??
        0;
  }

  Future<List<Review>> getRecentReviews(String userId, {int limit = 3}) async {
    final db = await database;
    final res = await db.query('reviews',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit);
    return res.map(Review.fromMap).toList();
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
