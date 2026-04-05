import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../database/db_helper.dart';
import 'aruba_http.dart';

/// Sincronizzazione recensioni SQLite locale ↔ MySQL Aruba.
/// Drop-in replacement di review_sync_service.dart (Supabase).
class ReviewSyncService {
  static final ReviewSyncService _instance = ReviewSyncService._();
  factory ReviewSyncService() => _instance;
  ReviewSyncService._();

  final _http = ArubaHttp();

  // ── Upsert singola recensione su Aruba (fire & forget) ─────────────────
  Future<void> upsert(Review review) async {
    if (!_http.isLoggedIn) return;
    try {
      await _http.post('user_reviews', {
        'user_id': review.userId,
        'book_id': review.bookId,
        'book_title': review.bookTitle,
        'book_author': review.bookAuthor,
        'book_cover_url': review.bookCoverUrl,
        'book_publisher': review.bookPublisher,
        'book_year': review.bookYear,
        'book_genre': review.bookGenre,
        'rating': review.rating,
        'review_title': review.reviewTitle,
        'review_body': review.reviewBody,
        'start_date': review.startDate,
        'end_date': review.endDate,
        'created_at': review.createdAt ?? DateTime.now().toIso8601String(),
        'updated_at': review.updatedAt,
      });
    } catch (e) {
      debugPrint('ReviewSyncService.upsert error: $e');
    }
  }

  // ── Elimina recensione da Aruba ────────────────────────────────────────
  Future<void> delete(String userId, String bookId) async {
    if (!_http.isLoggedIn) return;
    try {
      await _http.delete('user_reviews', {'book_id': bookId});
    } catch (e) {
      debugPrint('ReviewSyncService.delete error: $e');
    }
  }

  // ── Sincronizza dal cloud al dispositivo (al login) ───────────────────
  Future<int> syncFromCloud(String userId) async {
    if (!_http.isLoggedIn) return 0;
    int synced = 0;
    try {
      final data = await _http.get('user_reviews');
      if (data == null || data is! List) return 0;

      final db = DbHelper();
      for (final m in data) {
        final map = m as Map<String, dynamic>;
        try {
          final bookId = map['book_id'] as String?;
          if (bookId == null) continue;
          final existing = await db.getReviewForBook(userId, bookId);

          if (existing == null) {
            // Non esiste localmente: inserisci
            final review = _reviewFromCloud(map);
            await db.insertReview(review);
            synced++;
          } else {
            // Esiste: aggiorna solo se il cloud è più recente
            final cloudUpdated = DateTime.tryParse(
                    map['updated_at'] as String? ?? '') ??
                DateTime(0);
            final localUpdated =
                DateTime.tryParse(existing.updatedAt) ?? DateTime(0);
            if (cloudUpdated.isAfter(localUpdated)) {
              final review = _reviewFromCloud(map, localId: existing.id);
              await db.updateReview(review);
              synced++;
            }
          }
        } catch (e) {
          debugPrint('ReviewSyncService.syncFromCloud item error: $e');
        }
      }
    } catch (e) {
      debugPrint('ReviewSyncService.syncFromCloud error: $e');
    }
    return synced;
  }

  // ── Carica TUTTE le recensioni locali su Aruba (primo sync) ─────────────
  Future<void> uploadAll(String userId) async {
    if (!_http.isLoggedIn) return;
    try {
      final reviews = await DbHelper().getReviewsByUser(userId);
      for (final r in reviews) {
        await upsert(r);
      }
      debugPrint('ReviewSyncService.uploadAll: ${reviews.length} recensioni caricate');
    } catch (e) {
      debugPrint('ReviewSyncService.uploadAll error: $e');
    }
  }

  Review _reviewFromCloud(Map<String, dynamic> m, {int? localId}) => Review(
        id: localId,
        userId: m['user_id'] as String,
        bookId: m['book_id'] as String,
        bookTitle: m['book_title'] as String,
        bookAuthor: m['book_author'] as String,
        bookCoverUrl: m['book_cover_url'] as String?,
        bookPublisher: m['book_publisher'] as String?,
        bookYear: m['book_year'] as String?,
        bookGenre: m['book_genre'] as String?,
        rating: (m['rating'] as num?)?.toInt() ?? 0,
        reviewTitle: m['review_title'] as String?,
        reviewBody: m['review_body'] as String?,
        startDate: m['start_date'] as String?,
        endDate: m['end_date'] as String?,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      );
}
