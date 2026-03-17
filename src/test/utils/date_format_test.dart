import 'package:flutter_test/flutter_test.dart';
import 'package:book_review/utils/date_format.dart';

void main() {
  group('formatDateForDisplay', () {
    test('converte ISO 8601 in formato italiano', () {
      expect(formatDateForDisplay('2024-03-15'), '15/03/2024');
    });

    test('converte ISO 8601 con timestamp', () {
      expect(formatDateForDisplay('2024-12-25T10:30:00.000Z'), '25/12/2024');
    });

    test('restituisce stringa vuota per null', () {
      expect(formatDateForDisplay(null), '');
    });

    test('restituisce stringa vuota per stringa vuota', () {
      expect(formatDateForDisplay(''), '');
    });

    test('restituisce input originale per formato non valido', () {
      expect(formatDateForDisplay('non-una-data'), 'non-una-data');
    });

    test('gestisce primo giorno dell\'anno', () {
      expect(formatDateForDisplay('2024-01-01'), '01/01/2024');
    });

    test('gestisce ultimo giorno dell\'anno', () {
      expect(formatDateForDisplay('2024-12-31'), '31/12/2024');
    });

    test('pad singola cifra per giorno e mese', () {
      expect(formatDateForDisplay('2024-02-03'), '03/02/2024');
    });
  });
}
