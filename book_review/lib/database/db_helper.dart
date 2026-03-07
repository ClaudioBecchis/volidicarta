import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/review.dart';

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
    final path = join(dbPath, 'bookshelf.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
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
        read_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        UNIQUE(user_id, book_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE reviews ADD COLUMN book_genre TEXT');
    }
  }

  // --- Users ---

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query('users',
        where: 'username = ?', whereArgs: [username]);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final res =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<bool> usernameExists(String username) async {
    return await getUserByUsername(username) != null;
  }

  Future<bool> emailExists(String email) async {
    return await getUserByEmail(email) != null;
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

  Future<List<Review>> getReviewsByUser(int userId) async {
    final db = await database;
    final res = await db.query('reviews',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC');
    return res.map(Review.fromMap).toList();
  }

  Future<Review?> getReviewForBook(int userId, String bookId) async {
    final db = await database;
    final res = await db.query('reviews',
        where: 'user_id = ? AND book_id = ?', whereArgs: [userId, bookId]);
    if (res.isEmpty) return null;
    return Review.fromMap(res.first);
  }

  Future<List<Review>> searchReviews(int userId, String query) async {
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

  Future<Map<String, dynamic>> getStats(int userId) async {
    final db = await database;
    final total = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM reviews WHERE user_id = ?', [userId])) ??
        0;
    final avgRow = await db.rawQuery(
        'SELECT AVG(rating) as avg FROM reviews WHERE user_id = ?', [userId]);
    final avg = avgRow.first['avg'];
    final dist = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      dist[i] = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT COUNT(*) FROM reviews WHERE user_id = ? AND rating = ?',
              [userId, i])) ??
          0;
    }
    return {'total': total, 'avg': avg, 'distribution': dist};
  }
}
