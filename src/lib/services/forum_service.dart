import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/forum_thread.dart';
import '../models/forum_reply.dart';

class ForumService {
  SupabaseClient? get _client =>
      SupabaseConfig.isInitialized ? Supabase.instance.client : null;

  String get _myId => _client?.auth.currentUser?.id ?? '';

  // ── Thread ────────────────────────────────────────────────────────────────

  Future<List<ForumThread>> fetchThreads({
    String? category,
    int limit = 30,
    int offset = 0,
  }) async {
    final client = _client;
    if (client == null) return [];
    try {
      final base = client
          .from('forum_threads')
          .select('*, forum_thread_likes(user_id)');
      final List data;
      if (category != null && category != 'Tutti') {
        data = await base
            .eq('category', category)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      } else {
        data = await base
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }
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
    final client = _client;
    if (client == null) return null;
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      final username = user.userMetadata?['username'] as String? ??
          user.email?.split('@').first ??
          'Utente';
      final data = await client
          .from('forum_threads')
          .insert({
            'user_id': user.id,
            'username': username,
            'title': title,
            'body': body?.isEmpty == true ? null : body,
            'category': category,
          })
          .select('*, forum_thread_likes(user_id)')
          .single();
      return ForumThread.fromMap(data, _myId);
    } catch (e) {
      debugPrint('ForumService.createThread error: $e');
      return null;
    }
  }

  Future<void> deleteThread(String threadId) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('forum_threads').delete().eq('id', threadId);
    } catch (e) {
      debugPrint('ForumService.deleteThread error: $e');
    }
  }

  Future<ForumThread> toggleThreadLike(ForumThread thread) async {
    final client = _client;
    if (client == null) return thread;
    try {
      if (thread.isLikedByMe) {
        await client
            .from('forum_thread_likes')
            .delete()
            .eq('user_id', _myId)
            .eq('thread_id', thread.id);
        return thread.copyWith(
          likesCount: thread.likesCount - 1,
          isLikedByMe: false,
        );
      } else {
        await client.from('forum_thread_likes').insert({
          'user_id': _myId,
          'thread_id': thread.id,
        });
        return thread.copyWith(
          likesCount: thread.likesCount + 1,
          isLikedByMe: true,
        );
      }
    } catch (e) {
      debugPrint('ForumService.toggleThreadLike error: $e');
      return thread;
    }
  }

  // ── Replies ───────────────────────────────────────────────────────────────

  Future<List<ForumReply>> fetchReplies(String threadId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final data = await client
          .from('forum_replies')
          .select('*, forum_reply_likes(user_id)')
          .eq('thread_id', threadId)
          .order('created_at', ascending: true);
      return (data as List)
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
    final client = _client;
    if (client == null) return null;
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      final username = user.userMetadata?['username'] as String? ??
          user.email?.split('@').first ??
          'Utente';
      final data = await client
          .from('forum_replies')
          .insert({
            'thread_id': threadId,
            'user_id': user.id,
            'username': username,
            'body': body,
          })
          .select('*, forum_reply_likes(user_id)')
          .single();
      // Aggiorna replies_count sul thread
      await client.rpc('increment_replies_count', params: {'thread_id_param': threadId});
      return ForumReply.fromMap(data, _myId);
    } catch (e) {
      debugPrint('ForumService.createReply error: $e');
      return null;
    }
  }

  Future<void> deleteReply(ForumReply reply) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('forum_replies').delete().eq('id', reply.id);
      await client.rpc('decrement_replies_count',
          params: {'thread_id_param': reply.threadId});
    } catch (e) {
      debugPrint('ForumService.deleteReply error: $e');
    }
  }

  Future<ForumReply> toggleReplyLike(ForumReply reply) async {
    final client = _client;
    if (client == null) return reply;
    try {
      if (reply.isLikedByMe) {
        await client
            .from('forum_reply_likes')
            .delete()
            .eq('user_id', _myId)
            .eq('reply_id', reply.id);
        return reply.copyWith(
          likesCount: reply.likesCount - 1,
          isLikedByMe: false,
        );
      } else {
        await client.from('forum_reply_likes').insert({
          'user_id': _myId,
          'reply_id': reply.id,
        });
        return reply.copyWith(
          likesCount: reply.likesCount + 1,
          isLikedByMe: true,
        );
      }
    } catch (e) {
      debugPrint('ForumService.toggleReplyLike error: $e');
      return reply;
    }
  }
}
