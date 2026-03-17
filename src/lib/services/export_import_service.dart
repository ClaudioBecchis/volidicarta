import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../models/review.dart';
import '../models/wishlist_book.dart';

/// Servizio per esportazione/importazione dati utente in JSON/CSV.
class ExportImportService {
  static final ExportImportService _instance = ExportImportService._();
  factory ExportImportService() => _instance;
  ExportImportService._();

  // ── Esportazione JSON ────────────────────────────────────────────────────

  /// Esporta tutte le recensioni e la wishlist in un file JSON.
  /// Restituisce il percorso del file generato.
  Future<String> exportToJson(String userId) async {
    if (kIsWeb) {
      throw UnsupportedError('Export JSON non supportato su Web. Usa la versione desktop o mobile.');
    }
    final db = DbHelper();
    final reviews = await db.getReviewsByUser(userId);
    final wishlist = await db.getWishlist(userId);

    final data = {
      'app': 'Voli di Carta',
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'user_id': userId,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'wishlist': wishlist.map((w) => w.toMap()).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await _getExportDir();
    final file = File('${dir.path}/volidicarta_export.json');
    await file.writeAsString(json);
    return file.path;
  }

  // ── Esportazione CSV ─────────────────────────────────────────────────────

  /// Esporta le recensioni in formato CSV.
  Future<String> exportReviewsToCsv(String userId) async {
    if (kIsWeb) {
      throw UnsupportedError('Export CSV non supportato su Web. Usa la versione desktop o mobile.');
    }
    final reviews = await DbHelper().getReviewsByUser(userId);
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Titolo,Autore,Editore,Anno,Genere,Valutazione,Titolo Recensione,'
      'Corpo Recensione,Data Inizio,Data Fine,Creata il',
    );

    // Righe
    for (final r in reviews) {
      buffer.writeln([
        _csvEscape(r.bookTitle),
        _csvEscape(r.bookAuthor),
        _csvEscape(r.bookPublisher ?? ''),
        _csvEscape(r.bookYear ?? ''),
        _csvEscape(r.bookGenre ?? ''),
        r.rating.toString(),
        _csvEscape(r.reviewTitle ?? ''),
        _csvEscape(r.reviewBody ?? ''),
        _csvEscape(r.startDate ?? ''),
        _csvEscape(r.endDate ?? ''),
        _csvEscape(r.createdAt ?? ''),
      ].join(','));
    }

    final dir = await _getExportDir();
    final file = File('${dir.path}/volidicarta_reviews.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  // ── Importazione JSON ────────────────────────────────────────────────────

  /// Importa dati da un file JSON. Restituisce (recensioni importate, wishlist importati).
  Future<({int reviews, int wishlist})> importFromJson(
      String filePath, String userId) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File non trovato: $filePath');
    }

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    // Validazione base
    if (data['app'] != 'Voli di Carta') {
      throw Exception('File non valido: non è un export di Voli di Carta');
    }

    final db = DbHelper();
    var reviewCount = 0;
    var wishlistCount = 0;

    // Importa recensioni
    final reviewsList = data['reviews'] as List? ?? [];
    for (final item in reviewsList) {
      try {
        final map = item as Map<String, dynamic>;
        map['user_id'] = userId; // Forza l'utente corrente
        map['id'] = null; // Rimuovi ID locale
        final review = Review.fromMap(map);
        await db.insertReview(review);
        reviewCount++;
      } catch (e) {
        debugPrint('Import review error: $e');
      }
    }

    // Importa wishlist
    final wishlistList = data['wishlist'] as List? ?? [];
    for (final item in wishlistList) {
      try {
        final map = item as Map<String, dynamic>;
        map['user_id'] = userId;
        map['id'] = null;
        final book = WishlistBook.fromMap(map);
        await db.addToWishlist(book);
        wishlistCount++;
      } catch (e) {
        debugPrint('Import wishlist error: $e');
      }
    }

    return (reviews: reviewCount, wishlist: wishlistCount);
  }

  // ── Condivisione ─────────────────────────────────────────────────────────

  /// Condivide il file esportato tramite il dialog di sistema.
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Voli di Carta — Export dati',
    );
  }

  // ── Utilità ──────────────────────────────────────────────────────────────

  Future<Directory> _getExportDir() async {
    if (kIsWeb) {
      throw UnsupportedError('Export non supportato su Web');
    }
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/VoliDiCarta');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
