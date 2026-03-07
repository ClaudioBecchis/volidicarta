import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/public_review.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  String? get currentUsername {
    // Stored in user_metadata at registration
    return currentUser?.userMetadata?['username'] as String?;
  }

  Future<String?> signUp(String username, String email, String password) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user == null) return 'Registrazione fallita';
      // Create profile row
      await _client.from('profiles').upsert({
        'id': res.user!.id,
        'username': username,
      });
      return null; // success
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'Errore di rete: ${e.toString()}';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'Errore di rete: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _translateAuthError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'Email già registrata nella community';
    }
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'Email o password errata';
    }
    if (m.contains('email not confirmed')) {
      return 'Controlla la tua email per confermare l\'account';
    }
    if (m.contains('password')) return 'Password troppo corta (min 6 caratteri)';
    return msg;
  }

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<List<PublicReview>> fetchFeed({int limit = 30, int offset = 0}) async {
    try {
      final data = await _client
          .from('public_reviews')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final reviews = (data as List).map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();

      // Se l'utente è loggato, recupera i like
      if (isLoggedIn && reviews.isNotEmpty) {
        final ids = reviews.map((r) => r.id).toList();
        final likes = await _client
            .from('likes')
            .select('review_id')
            .eq('user_id', currentUser!.id)
            .inFilter('review_id', ids);
        final likedIds = {for (final l in (likes as List)) l['review_id'] as String};
        for (final r in reviews) {
          r.isLikedByMe = likedIds.contains(r.id);
        }
      }
      return reviews;
    } catch (_) {
      return [];
    }
  }

  Future<List<PublicReview>> fetchMyPublicReviews() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client
          .from('public_reviews')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
      return (data as List).map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Publish / Delete ──────────────────────────────────────────────────────

  Future<String?> publishReview(PublicReview review) async {
    if (!isLoggedIn) return 'Accedi alla community per condividere';
    try {
      // Controlla se già pubblicata
      final existing = await _client
          .from('public_reviews')
          .select('id')
          .eq('user_id', currentUser!.id)
          .eq('book_id', review.bookId)
          .maybeSingle();
      if (existing != null) {
        // Aggiorna
        await _client
            .from('public_reviews')
            .update(review.toInsertMap())
            .eq('id', existing['id'] as String);
      } else {
        await _client.from('public_reviews').insert(review.toInsertMap());
      }
      return null;
    } catch (e) {
      return 'Errore pubblicazione: $e';
    }
  }

  Future<void> deletePublicReview(String reviewId) async {
    await _client.from('public_reviews').delete().eq('id', reviewId);
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  Future<bool> toggleLike(PublicReview review) async {
    if (!isLoggedIn) return review.isLikedByMe;
    try {
      if (review.isLikedByMe) {
        await _client
            .from('likes')
            .delete()
            .eq('user_id', currentUser!.id)
            .eq('review_id', review.id);
        review.isLikedByMe = false;
        review.likesCount = (review.likesCount - 1).clamp(0, 9999);
      } else {
        await _client.from('likes').insert({
          'user_id': currentUser!.id,
          'review_id': review.id,
        });
        review.isLikedByMe = true;
        review.likesCount++;
      }
      return review.isLikedByMe;
    } catch (_) {
      return review.isLikedByMe;
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      return await _client.from('profiles').select().eq('id', userId).single();
    } catch (_) {
      return null;
    }
  }

  Future<List<PublicReview>> fetchUserReviews(String userId) async {
    try {
      final data = await _client
          .from('public_reviews')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List).map((m) => PublicReview.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
