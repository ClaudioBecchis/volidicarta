import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/models/review.dart';

void main() {
  group('Review model', () {
    final now = DateTime.now().toIso8601String();

    test('crea recensione con tutti i campi obbligatori', () {
      final review = Review(
        userId: 'user-123',
        bookId: 'book-456',
        bookTitle: 'Il Nome della Rosa',
        bookAuthor: 'Umberto Eco',
        rating: 5,
        updatedAt: now,
      );

      expect(review.userId, 'user-123');
      expect(review.bookId, 'book-456');
      expect(review.rating, 5);
      expect(review.id, isNull);
      expect(review.reviewTitle, isNull);
      expect(review.startDate, isNull);
    });

    test('toMap serializza tutti i campi', () {
      final review = Review(
        id: 1,
        userId: 'user-123',
        bookId: 'book-456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookCoverUrl: 'https://example.com/cover.jpg',
        bookPublisher: 'Publisher',
        bookYear: '2024',
        bookGenre: 'Fantasy',
        rating: 4,
        reviewTitle: 'Ottimo',
        reviewBody: 'Bel libro',
        startDate: '2024-01-01',
        endDate: '2024-02-15',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: now,
      );

      final map = review.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 'user-123');
      expect(map['book_id'], 'book-456');
      expect(map['rating'], 4);
      expect(map['review_title'], 'Ottimo');
      expect(map['book_genre'], 'Fantasy');
      expect(map['start_date'], '2024-01-01');
      expect(map['end_date'], '2024-02-15');
    });

    test('toMap genera created_at se null', () {
      final review = Review(
        userId: 'u', bookId: 'b', bookTitle: 't', bookAuthor: 'a',
        rating: 3, updatedAt: now,
      );
      final map = review.toMap();
      expect(map['created_at'], isNotNull);
      expect(map['created_at'], isA<String>());
    });

    test('fromMap deserializza correttamente', () {
      final map = {
        'id': 42,
        'user_id': 'user-abc',
        'book_id': 'book-xyz',
        'book_title': 'Titolo',
        'book_author': 'Autore',
        'book_cover_url': null,
        'book_publisher': 'Editore',
        'book_year': '2023',
        'book_genre': 'Giallo',
        'rating': 3,
        'review_title': 'Decente',
        'review_body': 'Leggibile',
        'start_date': '2023-06-01',
        'end_date': '2023-07-15',
        'created_at': '2023-06-01T00:00:00.000Z',
        'updated_at': '2023-07-15T00:00:00.000Z',
      };

      final review = Review.fromMap(map);

      expect(review.id, 42);
      expect(review.userId, 'user-abc');
      expect(review.bookGenre, 'Giallo');
      expect(review.rating, 3);
      expect(review.endDate, '2023-07-15');
    });

    test('toMap → fromMap roundtrip preserva i dati', () {
      final original = Review(
        id: 10,
        userId: 'u1',
        bookId: 'b1',
        bookTitle: 'Roundtrip',
        bookAuthor: 'Author',
        rating: 5,
        reviewTitle: 'Perfetto',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-02T00:00:00.000Z',
      );

      final restored = Review.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.bookId, original.bookId);
      expect(restored.rating, original.rating);
      expect(restored.reviewTitle, original.reviewTitle);
    });

    test('copyWith aggiorna solo i campi specificati', () {
      final review = Review(
        userId: 'u', bookId: 'b', bookTitle: 't', bookAuthor: 'a',
        rating: 3, updatedAt: now, bookGenre: 'Fantasy',
      );

      final updated = review.copyWith(rating: 5, reviewTitle: 'Migliore');

      expect(updated.rating, 5);
      expect(updated.reviewTitle, 'Migliore');
      expect(updated.bookGenre, 'Fantasy'); // non modificato
      expect(updated.userId, 'u'); // non modificato
      // updatedAt viene rinnovato
      expect(updated.updatedAt, isNot(equals(now)));
    });
  });
}
