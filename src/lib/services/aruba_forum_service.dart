import 'package:flutter/foundation.dart';
import '../models/forum_thread.dart';
import '../models/forum_reply.dart';
import 'aruba_http.dart';

/// Servizio forum — backend Aruba (PHP + MySQL).
/// Drop-in replacement di forum_service.dart (Supabase).
class ForumService {
  final _http = ArubaHttp();

  String get _myId => _http.userId ?? '';

  // ── Thread ────────────────────────────────────────────────────────────────

  Future<List<ForumThread>> fetchThreads({
    String? category,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (category != null && category != 'Tutti') {
        params['category'] = category;
      }
      final data = await _http.get('forum_threads', params);
      if (data == null || data is! List) return [];
      return data
          .map((m) => ForumThread.fromMap(m as Map<String, dynamic>, _myId))
          .toList();
    } catch (e) {
      debugPrint('ForumService.fetchThreads error: $e');
      return [];
    }
  }

  Future<ForumThread?> createThread({
    required String title,
    required String category,
    String? body,
  }) async {
    try {
      final data = await _http.post('forum_threads', {
        'title': title,
        'body': body?.isEmpty == true ? null : body,
        'category': category,
      });
      if (data == null || data['error'] != null) return null;
      return ForumThread.fromMap(data as Map<String, dynamic>, _myId);
    } catch (e) {
      debugPrint('ForumService.createThread error: $e');
      return null;
    }
  }

  Future<void> deleteThread(String threadId) async {
    try {
      await _http.delete('forum_threads', {'id': threadId});
    } catch (e) {
      debugPrint('ForumService.deleteThread error: $e');
    }
  }

  Future<({ForumThread thread, String? error})> toggleThreadLike(ForumThread thread) async {
    if (_myId.isEmpty) {
      return (thread: thread, error: 'login_required');
    }
    try {
      if (thread.isLikedByMe) {
        await _http.delete('forum_thread_likes', {'thread_id': thread.id});
        return (
          thread: thread.copyWith(
            likesCount: (thread.likesCount - 1).clamp(0, 9999),
            isLikedByMe: false,
          ),
          error: null,
        );
      } else {
        await _http.post('forum_thread_likes', {'thread_id': thread.id});
        return (
          thread: thread.copyWith(
            likesCount: thread.likesCount + 1,
            isLikedByMe: true,
          ),
          error: null,
        );
      }
    } catch (e) {
      debugPrint('ForumService.toggleThreadLike error: $e');
      return (thread: thread, error: 'Errore di rete. Riprova.');
    }
  }

  // ── Replies ───────────────────────────────────────────────────────────────

  Future<List<ForumReply>> fetchReplies(String threadId) async {
    try {
      final data = await _http.get('forum_replies', {'thread_id': threadId});
      if (data == null || data is! List) return [];
      return data
          .map((m) => ForumReply.fromMap(m as Map<String, dynamic>, _myId))
          .toList();
    } catch (e) {
      debugPrint('ForumService.fetchReplies error: $e');
      return [];
    }
  }

  Future<ForumReply?> createReply({
    required String threadId,
    required String body,
  }) async {
    try {
      final data = await _http.post('forum_replies', {
        'thread_id': threadId,
        'body': body,
      });
      if (data == null || data['error'] != null) return null;
      return ForumReply.fromMap(data as Map<String, dynamic>, _myId);
    } catch (e) {
      debugPrint('ForumService.createReply error: $e');
      return null;
    }
  }

  Future<void> deleteReply(ForumReply reply) async {
    try {
      await _http.delete('forum_replies', {'id': reply.id});
    } catch (e) {
      debugPrint('ForumService.deleteReply error: $e');
    }
  }

  Future<({ForumReply reply, String? error})> toggleReplyLike(ForumReply reply) async {
    if (_myId.isEmpty) {
      return (reply: reply, error: 'login_required');
    }
    try {
      if (reply.isLikedByMe) {
        await _http.delete('forum_reply_likes', {'reply_id': reply.id});
        return (
          reply: reply.copyWith(
            likesCount: (reply.likesCount - 1).clamp(0, 9999),
            isLikedByMe: false,
          ),
          error: null,
        );
      } else {
        await _http.post('forum_reply_likes', {'reply_id': reply.id});
        return (
          reply: reply.copyWith(
            likesCount: reply.likesCount + 1,
            isLikedByMe: true,
          ),
          error: null,
        );
      }
    } catch (e) {
      debugPrint('ForumService.toggleReplyLike error: $e');
      return (reply: reply, error: 'Errore di rete. Riprova.');
    }
  }
}
