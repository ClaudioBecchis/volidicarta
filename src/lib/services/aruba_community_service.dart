import 'package:flutter/foundation.dart';
import '../models/public_review.dart';
import 'aruba_http.dart';

/// Servizio community — backend Aruba (PHP + MySQL).
/// Drop-in replacement di supabase_service.dart.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  final _http = ArubaHttp();

  bool get isLoggedIn => _http.isLoggedIn;
  String? get currentUserId => _http.userId;
  String? get currentUsername => _http.username;

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<List<PublicReview>> fetchFeed({int limit = 30, int offset = 0}) async {
    try {
      final data = await _http.get('public_reviews', {
        'limit': '$limit',
        'offset': '$offset',
      });
      if (data == null || data is! List) return [];
      final reviews = data.map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();

      // Recupera i like dell'utente corrente
      if (isLoggedIn && reviews.isNotEmpty) {
        final ids = reviews.map((r) => r.id).join(',');
        final likes = await _http.get('likes', {
          'review_ids': ids,
        });
        if (likes != null && likes is List) {
          final likedIds = {for (final l in likes) l['review_id'] as String};
          for (final r in reviews) {
            r.isLikedByMe = likedIds.contains(r.id);
          }
        }
      }
      return reviews;
    } catch (e) {
      debugPrint('fetchFeed error: $e');
      return [];
    }
  }

  Future<List<PublicReview>> fetchMyPublicReviews() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _http.get('public_reviews', {
        'user_id': _http.userId!,
      });
      if (data == null || data is! List) return [];
      return data.map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Publish / Delete ──────────────────────────────────────────────────────

  Future<String?> publishReview(PublicReview review) async {
    if (!isLoggedIn) return 'Accedi alla community per condividere';
    try {
      final res = await _http.post('public_reviews', review.toInsertMap());
      if (res == null) return 'Errore di connessione.';
      if (res['error'] != null) return res['error'] as String;
      return null;
    } catch (e) {
      return 'Errore pubblicazione: $e';
    }
  }

  Future<void> deletePublicReview(String reviewId) async {
    await _http.delete('public_reviews', {'id': reviewId});
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  Future<({PublicReview review, String? error})> toggleLike(PublicReview review) async {
    if (!isLoggedIn) {
      return (review: review, error: 'login_required');
    }
    try {
      if (review.isLikedByMe) {
        await _http.delete('likes', {'review_id': review.id});
        return (
          review: review.copyWith(
            isLikedByMe: false,
            likesCount: (review.likesCount - 1).clamp(0, 9999),
          ),
          error: null,
        );
      } else {
        await _http.post('likes', {'review_id': review.id});
        return (
          review: review.copyWith(
            isLikedByMe: true,
            likesCount: review.likesCount + 1,
          ),
          error: null,
        );
      }
    } catch (e) {
      debugPrint('toggleLike error: $e');
      return (review: review, error: 'Errore di rete. Riprova.');
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      return await _http.get('profile', {'id': userId}) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<List<PublicReview>> fetchUserReviews(String userId) async {
    try {
      final data = await _http.get('public_reviews', {'user_id': userId});
      if (data == null || data is! List) return [];
      return data.map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Presence ──────────────────────────────────────────────────────────────

  Future<void> updatePresence({String platform = 'unknown'}) async {
    try {
      await _http.post('update_presence', {'platform': platform});
    } catch (_) {}
  }

  Future<({int totalUsers, int onlineUsers, int offlineUsers, int anonOnline})> getCommunityStats() async {
    try {
      final data = await _http.get('community_stats');
      if (data == null || data is! Map) {
        return (totalUsers: 0, onlineUsers: 0, offlineUsers: 0, anonOnline: 0);
      }
      return (
        totalUsers: (data['total_users'] as num?)?.toInt() ?? 0,
        onlineUsers: (data['online_users'] as num?)?.toInt() ?? 0,
        offlineUsers: (data['offline_users'] as num?)?.toInt() ?? 0,
        anonOnline: (data['anon_online'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return (totalUsers: 0, onlineUsers: 0, offlineUsers: 0, anonOnline: 0);
    }
  }

  Future<String?> deleteAccount() async {
    if (!isLoggedIn) return 'Non sei autenticato.';
    try {
      final res = await _http.post('delete_account');
      if (res == null) return 'Errore di connessione.';
      if (res['error'] != null) return res['error'] as String;
      await _http.clearSession();
      return null;
    } catch (e) {
      return 'Errore: $e';
    }
  }

  Future<void> updateAnonPresence(String sessionId, String platform) async {
    try {
      await _http.post('update_anon_presence', {
        'session_id': sessionId,
        'platform': platform,
      });
    } catch (_) {}
  }
}
