import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/models/wishlist_book.dart';

void main() {
  group('WishlistBook model', () {
    test('toMap serializza tutti i campi', () {
      final book = WishlistBook(
        id: 1,
        userId: 'user-1',
        bookId: 'book-1',
        bookTitle: 'Da Leggere',
        bookAuthor: 'Autore',
        bookCoverUrl: 'https://example.com/cover.jpg',
        bookPublisher: 'Editore',
        bookYear: '2024',
        bookGenre: 'Sci-Fi',
        notes: 'Consigliato da Mario',
        addedAt: '2024-03-15T10:00:00.000Z',
      );

      final map = book.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 'user-1');
      expect(map['book_id'], 'book-1');
      expect(map['book_title'], 'Da Leggere');
      expect(map['notes'], 'Consigliato da Mario');
      expect(map['book_genre'], 'Sci-Fi');
    });

    test('fromMap deserializza correttamente', () {
      final map = {
        'id': 5,
        'user_id': 'u1',
        'book_id': 'b1',
        'book_title': 'Titolo',
        'book_author': 'Autore',
        'book_cover_url': null,
        'book_publisher': null,
        'book_year': null,
        'book_genre': null,
        'notes': null,
        'added_at': '2024-01-01T00:00:00.000Z',
      };

      final book = WishlistBook.fromMap(map);

      expect(book.id, 5);
      expect(book.bookTitle, 'Titolo');
      expect(book.bookCoverUrl, isNull);
      expect(book.notes, isNull);
    });

    test('toMap → fromMap roundtrip', () {
      final original = WishlistBook(
        userId: 'u', bookId: 'b', bookTitle: 't',
        bookAuthor: 'a', addedAt: '2024-01-01',
      );

      final restored = WishlistBook.fromMap(original.toMap());

      expect(restored.userId, original.userId);
      expect(restored.bookId, original.bookId);
      expect(restored.bookTitle, original.bookTitle);
    });
  });
}
