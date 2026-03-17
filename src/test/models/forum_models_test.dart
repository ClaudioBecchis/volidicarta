import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/models/forum_thread.dart';
import 'package:book_review/models/forum_reply.dart';

void main() {
  group('ForumThread model', () {
    test('fromMap parsa thread con like personale', () {
      final map = {
        'id': 'thread-1',
        'user_id': 'user-a',
        'username': 'mario',
        'title': 'Miglior libro del 2024?',
        'body': 'Qual è il vostro preferito?',
        'category': 'Discussioni',
        'created_at': '2024-01-01T00:00:00.000Z',
        'replies_count': 5,
        'likes_count': 3,
        'forum_thread_likes': [
          {'user_id': 'user-a'},
          {'user_id': 'user-b'},
          {'user_id': 'my-user'},
        ],
      };

      final thread = ForumThread.fromMap(map, 'my-user');

      expect(thread.id, 'thread-1');
      expect(thread.title, 'Miglior libro del 2024?');
      expect(thread.repliesCount, 5);
      expect(thread.likesCount, 3);
      expect(thread.isLikedByMe, true);
    });

    test('fromMap senza like personale', () {
      final map = {
        'id': 'thread-2',
        'user_id': 'user-a',
        'username': 'mario',
        'title': 'Test',
        'category': 'Consigli',
        'created_at': '2024-01-01',
        'replies_count': 0,
        'likes_count': 0,
        'forum_thread_likes': [],
      };

      final thread = ForumThread.fromMap(map, 'my-user');
      expect(thread.isLikedByMe, false);
    });

    test('fromMap gestisce null e fallback', () {
      final map = {
        'id': 'thread-3',
        'user_id': 'u',
        'username': null,
        'title': 'T',
        'category': null,
        'created_at': null,
        'replies_count': null,
        'likes_count': null,
      };

      final thread = ForumThread.fromMap(map, 'x');
      expect(thread.username, 'Utente');
      expect(thread.category, 'Generale');
      expect(thread.repliesCount, 0);
      expect(thread.likesCount, 0);
    });

    test('copyWith aggiorna solo i campi specificati', () {
      final thread = ForumThread(
        id: 't1', userId: 'u', username: 'test', title: 'T',
        category: 'C', createdAt: 'now',
        repliesCount: 0, likesCount: 0, isLikedByMe: false,
      );

      final liked = thread.copyWith(isLikedByMe: true, likesCount: 1);

      expect(liked.isLikedByMe, true);
      expect(liked.likesCount, 1);
      expect(liked.title, 'T'); // invariato
    });
  });

  group('ForumReply model', () {
    test('fromMap parsa reply con like', () {
      final map = {
        'id': 'reply-1',
        'thread_id': 'thread-1',
        'user_id': 'user-a',
        'username': 'luigi',
        'body': 'Bella domanda!',
        'created_at': '2024-01-02',
        'likes_count': 2,
        'forum_reply_likes': [
          {'user_id': 'my-user'},
        ],
      };

      final reply = ForumReply.fromMap(map, 'my-user');

      expect(reply.id, 'reply-1');
      expect(reply.body, 'Bella domanda!');
      expect(reply.likesCount, 2);
      expect(reply.isLikedByMe, true);
    });

    test('copyWith aggiorna like', () {
      final reply = ForumReply(
        id: 'r1', threadId: 't1', userId: 'u',
        username: 'test', body: 'ciao',
        createdAt: 'now', likesCount: 0, isLikedByMe: false,
      );

      final liked = reply.copyWith(isLikedByMe: true, likesCount: 1);

      expect(liked.isLikedByMe, true);
      expect(liked.likesCount, 1);
      expect(liked.body, 'ciao');
    });
  });
}
