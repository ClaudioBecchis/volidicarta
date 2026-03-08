import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:book_review/database/db_helper.dart';
import 'package:book_review/screens/about_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    // Chiudi e resetta il singleton tra test
    await DbHelper().close();
  });

  group('DbHelper — statistiche', () {
    test('avg è null se nessuna recensione', () async {
      final stats = await DbHelper().getStats('nonexistent-user');
      expect(stats['total'], equals(0));
      expect(stats['avg'], isNull);
    });

    test('getStatsByGenre restituisce mappa vuota per utente senza recensioni',
        () async {
      final genres = await DbHelper().getStatsByGenre('nonexistent-user');
      expect(genres, isEmpty);
    });

    test('getStatsByYear restituisce mappa vuota per utente senza recensioni',
        () async {
      final years = await DbHelper().getStatsByYear('nonexistent-user');
      expect(years, isEmpty);
    });

    test('wishlistCount è 0 per utente senza wishlist', () async {
      final count = await DbHelper().wishlistCount('nonexistent-user');
      expect(count, equals(0));
    });
  });

  group('AboutScreen — semver isNewerVersion', () {
    test('1.0.10 > 1.0.9 → true', () {
      expect(AboutScreen.isNewerVersion('1.0.10', '1.0.9'), isTrue);
    });

    test('1.0.9 == 1.0.9 → false', () {
      expect(AboutScreen.isNewerVersion('1.0.9', '1.0.9'), isFalse);
    });

    test('1.0.8 < 1.0.9 → false', () {
      expect(AboutScreen.isNewerVersion('1.0.8', '1.0.9'), isFalse);
    });

    test('2.0.0 > 1.99.99 → true', () {
      expect(AboutScreen.isNewerVersion('2.0.0', '1.99.99'), isTrue);
    });

    test('1.1.0 > 1.0.9 → true', () {
      expect(AboutScreen.isNewerVersion('1.1.0', '1.0.9'), isTrue);
    });

    test('1.0.9 < 1.1.0 → false', () {
      expect(AboutScreen.isNewerVersion('1.0.9', '1.1.0'), isFalse);
    });

    test('stringa non valida → false (non crash)', () {
      expect(AboutScreen.isNewerVersion('invalid', 'invalid'), isFalse);
    });
  });
}
