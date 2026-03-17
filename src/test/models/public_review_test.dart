import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/models/public_review.dart';

void main() {
  group('PublicReview model', () {
    test('fromMap parsa dati Supabase correttamente', () {
      final map = {
        'id': 'uuid-1',
        'user_id': 'user-1',
        'username': 'mario',
        'book_id': 'book-1',
        'book_title': 'Test Book',
        'book_author': 'Author',
        'book_cover_url': 'https://example.com/cover.jpg',
        'book_publisher': 'Publisher',
        'book_year': '2024',
        'book_genre': 'Fantasy',
        'rating': 4,
        'review_title': 'Bello',
        'review_body': 'Molto bello',
        'read_date': '2024-06-15',
        'created_at': '2024-06-20T10:00:00.000Z',
        'likes_count': 5,
      };

      final review = PublicReview.fromMap(map);

      expect(review.id, 'uuid-1');
      expect(review.username, 'mario');
      expect(review.rating, 4);
      expect(review.likesCount, 5);
      expect(review.isLikedByMe, false); // default
      expect(review.bookGenre, 'Fantasy');
      expect(review.readDate, '2024-06-15');
    });

    test('fromMap gestisce username null', () {
      final map = {
        'id': 'uuid-2',
        'user_id': 'u',
        'username': null,
        'book_id': 'b',
        'book_title': 't',
        'book_author': 'a',
        'rating': 3,
        'likes_count': null,
        'created_at': null,
      };

      final review = PublicReview.fromMap(map);
      expect(review.username, 'Utente'); // fallback
      expect(review.likesCount, 0);
      expect(review.createdAt, isNotNull);
    });

    test('copyWith crea copia con modifiche', () {
      final review = PublicReview(
        id: 'id1', userId: 'u', username: 'test',
        bookId: 'b', bookTitle: 't', bookAuthor: 'a',
        rating: 3, createdAt: '2024-01-01',
        likesCount: 0, isLikedByMe: false,
      );

      final liked = review.copyWith(isLikedByMe: true, likesCount: 1);

      expect(liked.isLikedByMe, true);
      expect(liked.likesCount, 1);
      expect(liked.id, 'id1'); // invariato
      expect(liked.rating, 3); // invariato
    });

    test('toInsertMap esclude id, created_at, likes_count, isLikedByMe', () {
      final review = PublicReview(
        id: 'id1', userId: 'u', username: 'test',
        bookId: 'b', bookTitle: 't', bookAuthor: 'a',
        rating: 4, createdAt: '2024-01-01',
        likesCount: 10, isLikedByMe: true,
      );

      final map = review.toInsertMap();

      expect(map.containsKey('id'), false);
      expect(map.containsKey('created_at'), false);
      expect(map.containsKey('likes_count'), false);
      expect(map.containsKey('isLikedByMe'), false);
      expect(map['user_id'], 'u');
      expect(map['rating'], 4);
    });
  });
}
