import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';

class BookApiService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  // Cache in memoria: chiave = query+lang, valore = risultato
  static final _cache = <String, ({List<Book> books, String? error})>{};
  // Ultimo timestamp di chiamata API
  static DateTime? _lastCall;
  // Intervallo minimo tra chiamate (senza chiave API)
  static const _minInterval = Duration(milliseconds: 1500);

  String _addKey(String url) {
    if (AppConfig.hasGoogleApiKey) {
      return '$url&key=${AppConfig.googleBooksApiKey}';
    }
    return url;
  }

  Future<void> _throttle() async {
    if (AppConfig.hasGoogleApiKey) return; // con chiave non serve
    if (_lastCall != null) {
      final elapsed = DateTime.now().difference(_lastCall!);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastCall = DateTime.now();
  }

  Future<({List<Book> books, String? error})> search(
      String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final key = '${query.trim()}|it';
    if (_cache.containsKey(key)) return _cache[key]!;
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(_addKey(
        '$_base?q=$encoded&maxResults=$maxResults&langRestrict=it&printType=books'));
    final result = await _fetch(uri);
    if (result.error == null) _cache[key] = result;
    return result;
  }

  Future<({List<Book> books, String? error})> searchAll(
      String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final key = '${query.trim()}|all';
    if (_cache.containsKey(key)) return _cache[key]!;
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(_addKey(
        '$_base?q=$encoded&maxResults=$maxResults&printType=books'));
    final result = await _fetch(uri);
    if (result.error == null) _cache[key] = result;
    return result;
  }

  Future<({List<Book> books, String? error})> _fetch(Uri uri, {bool isRetry = false}) async {
    try {
      await _throttle();
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode == 429) {
        if (!isRetry) {
          // Aspetta 4 secondi e riprova una volta
          await Future.delayed(const Duration(seconds: 4));
          return _fetch(uri, isRetry: true);
        }
        return (books: <Book>[], error:
            'Limite Google Books raggiunto.\n'
            'Attendi qualche minuto e riprova, oppure aggiungi\n'
            'una chiave API gratuita in app_config.dart.');
      }
      if (res.statusCode != 200) {
        return (books: <Book>[], error: 'Errore server: ${res.statusCode}');
      }
      final data = jsonDecode(res.body);
      final items = data['items'] as List?;
      if (items == null) return (books: <Book>[], error: null);
      return (
        books: items.map((j) => Book.fromGoogleApi(j)).toList(),
        error: null
      );
    } on TimeoutException {
      return (books: <Book>[], error: 'Timeout: controlla la connessione internet');
    } catch (e) {
      return (books: <Book>[], error: 'Errore rete: ${e.toString()}');
    }
  }

  Future<Book?> getById(String id) async {
    try {
      final uri = Uri.parse('$_base/$id');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return Book.fromGoogleApi(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }
}
