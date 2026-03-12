import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';

class BookApiService {
  static const _googleBase = 'https://www.googleapis.com/books/v1/volumes';
  static const _openLibBase = 'https://openlibrary.org/search.json';

  // Cache in memoria: chiave = query+lang, valore = risultato (max 100 voci, TTL 30 min)
  static final _cache = <String, ({List<Book> books, String? error, DateTime ts})>{};
  static const _cacheMaxSize = 100;
  static const _cacheTtl = Duration(minutes: 30);
  // Ultimo timestamp di chiamata Google Books
  static DateTime? _lastCall;
  static const _minInterval = Duration(milliseconds: 500);

  String _addKey(String url) {
    if (AppConfig.hasGoogleApiKey) {
      return '$url&key=${AppConfig.googleBooksApiKey}';
    }
    return url;
  }

  Future<void> _throttle() async {
    if (AppConfig.hasGoogleApiKey) return;
    if (_lastCall != null) {
      final elapsed = DateTime.now().difference(_lastCall!);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastCall = DateTime.now();
  }

  // Costruisce la query effettiva per Google Books in base al tipo di ricerca
  String _buildQuery(String query, String searchType) {
    final q = query.trim();
    if (searchType == 'inauthor') return 'inauthor:"$q"';
    if (searchType == 'intitle') return 'intitle:"$q"';
    return q;
  }

  Future<({List<Book> books, String? error})> search(
      String query, {int maxResults = 30, String langRestrict = 'it', String searchType = 'all'}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final key = '${query.trim()}|$langRestrict|$searchType';
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (DateTime.now().difference(entry.ts) < _cacheTtl) {
        return (books: entry.books, error: entry.error);
      }
      _cache.remove(key);
    }

    final effectiveQuery = _buildQuery(query, searchType);

    // Per il filtro ITA: doppia ricerca parallela — con e senza langRestrict,
    // poi filtro client-side su language='it' e merge per coprire edizioni
    // italiane con metadati mancanti o errati.
    if (langRestrict == 'it') {
      final results = await Future.wait([
        _searchGoogle(effectiveQuery, maxResults: 40, langRestrict: 'it'),
        _searchGoogle(effectiveQuery, maxResults: 40),
        _searchOpenLibrary(query, maxResults: 20, lang: 'ita', searchType: searchType),
      ]);
      final withRestrict = results[0];
      final withoutRestrict = results[1];
      final openLib = results[2];

      final seenIds = <String>{};
      final merged = <Book>[];
      for (final b in withRestrict.books) {
        if (seenIds.add(b.id)) merged.add(b);
      }
      for (final b in withoutRestrict.books) {
        if (b.language == 'it' && seenIds.add(b.id)) merged.add(b);
      }
      // Aggiunge risultati Open Library se Google ha trovato poco
      if (merged.length < 10) {
        for (final b in openLib.books) {
          if (seenIds.add(b.id)) merged.add(b);
        }
      }

      if (merged.isEmpty && withRestrict.error != null) {
        if (openLib.error == null && openLib.books.isNotEmpty) {
          _addToCache(key, openLib);
          return openLib;
        }
        final fallback = await _searchOpenLibrary(query, maxResults: maxResults, lang: 'ita', searchType: searchType);
        if (fallback.error == null) _addToCache(key, fallback);
        return fallback;
      }
      final limited = (books: merged.take(40).toList(), error: null);
      _addToCache(key, limited);
      return limited;
    }

    final olLang = langRestrict == 'en' ? 'eng' : null;
    final results = await Future.wait([
      _searchGoogle(effectiveQuery, maxResults: 40, langRestrict: langRestrict == 'it' ? 'it' : langRestrict),
      _searchOpenLibrary(query, maxResults: 20, lang: olLang, searchType: searchType),
    ]);
    final googleResult = results[0];
    final olResult = results[1];

    if (googleResult.error != null && googleResult.books.isEmpty) {
      if (olResult.error == null) _addToCache(key, olResult);
      return olResult;
    }

    final seenIds = <String>{};
    final merged = <Book>[];
    for (final b in googleResult.books) {
      if (seenIds.add(b.id)) merged.add(b);
    }
    if (merged.length < 10) {
      for (final b in olResult.books) {
        if (seenIds.add(b.id)) merged.add(b);
      }
    }
    final result = (books: merged.take(40).toList(), error: null);
    _addToCache(key, result);
    return result;
  }

  Future<({List<Book> books, String? error})> searchAll(
      String query, {int maxResults = 30, String searchType = 'all'}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final key = '${query.trim()}|all|$searchType';
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (DateTime.now().difference(entry.ts) < _cacheTtl) {
        return (books: entry.books, error: entry.error);
      }
      _cache.remove(key);
    }
    final effectiveQuery = _buildQuery(query, searchType);
    final results = await Future.wait([
      _searchGoogle(effectiveQuery, maxResults: 40),
      _searchOpenLibrary(query, maxResults: 20, searchType: searchType),
    ]);
    final googleResult = results[0];
    final olResult = results[1];

    if (googleResult.error != null && googleResult.books.isEmpty) {
      if (olResult.error == null) _addToCache(key, olResult);
      return olResult;
    }

    final seenIds = <String>{};
    final merged = <Book>[];
    for (final b in googleResult.books) {
      if (seenIds.add(b.id)) merged.add(b);
    }
    if (merged.length < 15) {
      for (final b in olResult.books) {
        if (seenIds.add(b.id)) merged.add(b);
      }
    }
    final result = (books: merged.take(40).toList(), error: null);
    _addToCache(key, result);
    return result;
  }

  void _addToCache(String key, ({List<Book> books, String? error}) value) {
    if (_cache.length >= _cacheMaxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = (books: value.books, error: value.error, ts: DateTime.now());
  }

  Future<({List<Book> books, String? error})> _searchGoogle(
      String query, {int maxResults = 15, String? langRestrict}) async {
    final encoded = Uri.encodeQueryComponent(query.trim());
    var url = '$_googleBase?q=$encoded&maxResults=$maxResults&printType=books';
    if (langRestrict != null) url += '&langRestrict=$langRestrict';
    final uri = Uri.parse(_addKey(url));
    return _fetchGoogle(uri);
  }

  Future<({List<Book> books, String? error})> _fetchGoogle(Uri uri, {bool isRetry = false}) async {
    try {
      await _throttle();
      final res = await http.get(uri).timeout(const Duration(seconds: 7));
      if (res.statusCode == 429 || res.statusCode == 503) {
        if (!isRetry) {
          await Future.delayed(const Duration(seconds: 3));
          return _fetchGoogle(uri, isRetry: true);
        }
        return (books: <Book>[], error: 'google_limit');
      }
      if (res.statusCode != 200) {
        return (books: <Book>[], error: 'Errore server: ${res.statusCode}');
      }
      final data = jsonDecode(res.body);
      final items = data['items'] as List?;
      if (items == null) return (books: <Book>[], error: null);
      return (books: items.map((j) => Book.fromGoogleApi(j)).toList(), error: null);
    } on TimeoutException {
      return (books: <Book>[], error: 'timeout');
    } catch (e) {
      return (books: <Book>[], error: 'Errore rete: ${e.toString()}');
    }
  }

  Future<({List<Book> books, String? error})> _searchOpenLibrary(
      String query, {int maxResults = 15, String? lang, String searchType = 'all'}) async {
    try {
      final encoded = Uri.encodeQueryComponent(query.trim());
      final String searchParam;
      if (searchType == 'inauthor') {
        searchParam = 'author=$encoded';
      } else if (searchType == 'intitle') {
        searchParam = 'title=$encoded';
      } else {
        searchParam = 'q=$encoded';
      }
      var url = '$_openLibBase?$searchParam&limit=$maxResults&fields=key,title,author_name,cover_i,isbn,publisher,first_publish_year,number_of_pages_median,subject';
      if (lang != null) url += '&language=$lang';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        return (books: <Book>[], error: 'Open Library non disponibile (${res.statusCode}).');
      }
      final data = jsonDecode(res.body);
      final docs = data['docs'] as List?;
      if (docs == null || docs.isEmpty) return (books: <Book>[], error: null);
      return (
        books: docs.map((j) => Book.fromOpenLibrary(j as Map<String, dynamic>)).toList(),
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
      if (id.startsWith('ol_')) return null;
      final uri = Uri.parse(_addKey('$_googleBase/$id'));
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return Book.fromGoogleApi(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }
}
