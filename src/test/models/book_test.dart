import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/models/book.dart';

void main() {
  group('Book.fromGoogleApi', () {
    test('parsa risposta Google Books completa', () {
      final json = {
        'id': 'abc123',
        'volumeInfo': {
          'title': 'Il Nome della Rosa',
          'authors': ['Umberto Eco'],
          'description': 'Un romanzo storico',
          'publisher': 'Bompiani',
          'publishedDate': '1980',
          'pageCount': 512,
          'categories': ['Fiction', 'Mystery'],
          'language': 'it',
          'imageLinks': {
            'thumbnail': 'http://example.com/thumb.jpg',
            'large': 'http://example.com/large.jpg',
          },
          'industryIdentifiers': [
            {'type': 'ISBN_13', 'identifier': '9788845292613'},
            {'type': 'ISBN_10', 'identifier': '8845292614'},
          ],
          'previewLink': 'http://books.google.com/preview',
        },
        'accessInfo': {
          'pdf': {'isAvailable': false},
        },
      };

      final book = Book.fromGoogleApi(json);

      expect(book.id, 'abc123');
      expect(book.title, 'Il Nome della Rosa');
      expect(book.authors, 'Umberto Eco');
      expect(book.description, 'Un romanzo storico');
      expect(book.publisher, 'Bompiani');
      expect(book.publishedDate, '1980');
      expect(book.pageCount, 512);
      expect(book.categories, 'Fiction, Mystery');
      expect(book.language, 'it');
      expect(book.isbn, '9788845292613');
      // http → https
      expect(book.coverUrl, startsWith('https://'));
      expect(book.coverLargeUrl, startsWith('https://'));
      expect(book.pdfDownloadLink, isNull);
    });

    test('gestisce JSON minimo senza crash', () {
      final json = <String, dynamic>{
        'id': 'min1',
        'volumeInfo': <String, dynamic>{},
      };

      final book = Book.fromGoogleApi(json);

      expect(book.id, 'min1');
      expect(book.title, 'Titolo sconosciuto');
      expect(book.authors, 'Autore sconosciuto');
      expect(book.coverUrl, isNull);
      expect(book.isbn, isNull);
      expect(book.pageCount, isNull);
    });

    test('estrae PDF link quando disponibile', () {
      final json = {
        'id': 'pdf1',
        'volumeInfo': {'title': 'Test'},
        'accessInfo': {
          'pdf': {
            'isAvailable': true,
            'downloadLink': 'http://example.com/dl.pdf',
          },
        },
      };

      final book = Book.fromGoogleApi(json);
      expect(book.pdfDownloadLink, 'https://example.com/dl.pdf');
    });

    test('preferisce ISBN_13 su ISBN_10', () {
      final json = {
        'id': 'isbn1',
        'volumeInfo': {
          'title': 'Test',
          'industryIdentifiers': [
            {'type': 'ISBN_10', 'identifier': '1234567890'},
            {'type': 'ISBN_13', 'identifier': '9781234567890'},
          ],
        },
      };

      final book = Book.fromGoogleApi(json);
      expect(book.isbn, '9781234567890');
    });
  });

  group('Book.fromOpenLibrary', () {
    test('parsa risposta Open Library completa', () {
      final json = {
        'key': '/works/OL123W',
        'title': 'Il Pendolo di Foucault',
        'author_name': ['Umberto Eco'],
        'cover_i': 12345,
        'isbn': ['9788845200000', '884520000X'],
        'publisher': ['Bompiani', 'Feltrinelli'],
        'first_publish_year': 1988,
        'number_of_pages_median': 640,
        'subject': ['Fiction', 'Italy', 'Philosophy'],
      };

      final book = Book.fromOpenLibrary(json);

      expect(book.id, startsWith('ol_'));
      expect(book.title, 'Il Pendolo di Foucault');
      expect(book.authors, 'Umberto Eco');
      expect(book.coverUrl, contains('openlibrary.org'));
      expect(book.coverUrl, contains('-M.jpg'));
      expect(book.coverLargeUrl, contains('-L.jpg'));
      expect(book.isbn, '9788845200000');
      expect(book.publisher, 'Bompiani');
      expect(book.publishedDate, '1988');
      expect(book.pageCount, 640);
      expect(book.categories, 'Fiction, Italy, Philosophy');
    });

    test('gestisce JSON senza cover e isbn', () {
      final json = {
        'key': '/works/OL999W',
        'title': 'Libro Senza Cover',
      };

      final book = Book.fromOpenLibrary(json);

      expect(book.id, 'ol__works_OL999W');
      expect(book.title, 'Libro Senza Cover');
      expect(book.authors, 'Autore sconosciuto');
      expect(book.coverUrl, isNull);
      expect(book.coverLargeUrl, isNull);
    });
  });
}
