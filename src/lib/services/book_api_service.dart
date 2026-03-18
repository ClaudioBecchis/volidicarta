import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../config/app_config.dart';
import '../utils/retry_helper.dart';

class BookApiService {
  static const _googleBase = 'https://www.googleapis.com/books/v1/volumes';
  static const _openLibBase = 'https://openlibrary.org/search.json';
  static const _sbnBase = 'https://opac.sbn.it/opacmobilegw/search.json';

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

    // Per il filtro ITA: ricerca parallela su 4 fonti — Google (con/senza lang),
    // Open Library (con/senza lang) e OPAC SBN per autori emergenti e piccoli
    // editori non indicizzati da Google.
    if (langRestrict == 'it') {
      final results = await Future.wait([
        _searchGoogle(effectiveQuery, maxResults: 40, langRestrict: 'it'),
        _searchGoogle(effectiveQuery, maxResults: 40),
        _searchOpenLibrary(query, maxResults: 40, lang: 'ita', searchType: searchType),
        _searchOpenLibrary(query, maxResults: 20, searchType: searchType),
        _searchSbn(query, maxResults: 20),
      ]);
      final withRestrict = results[0];
      final withoutRestrict = results[1];
      final openLibIt = results[2];
      final openLibAll = results[3];
      final sbn = results[4];

      final seenIds = <String>{};
      final seenTitles = <String>{};
      final merged = <Book>[];

      void addUnique(Book b) {
        if (seenIds.add(b.id)) {
          final titleKey = '${b.title.toLowerCase()}|${b.authors.toLowerCase()}';
          if (seenTitles.add(titleKey)) merged.add(b);
        }
      }

      // 1. Google con filtro lingua (priorità alta)
      for (final b in withRestrict.books) { addUnique(b); }
      // 2. Google senza filtro, solo lingua IT
      for (final b in withoutRestrict.books) {
        if (b.language == 'it') addUnique(b);
      }
      // 3. SEMPRE include Open Library IT (autori emergenti)
      for (final b in openLibIt.books) { addUnique(b); }
      // 4. Open Library senza filtro (cattura metadati lingua mancanti)
      for (final b in openLibAll.books) { addUnique(b); }
      // 5. OPAC SBN — catalogo completo biblioteche italiane
      for (final b in sbn.books) { addUnique(b); }

      if (merged.isEmpty && withRestrict.error != null) {
        if (openLibIt.error == null && openLibIt.books.isNotEmpty) {
          _addToCache(key, openLibIt);
          return openLibIt;
        }
        if (sbn.error == null && sbn.books.isNotEmpty) {
          _addToCache(key, sbn);
          return sbn;
        }
        final fallback = await _searchOpenLibrary(query, maxResults: maxResults, lang: 'ita', searchType: searchType);
        if (fallback.error == null) _addToCache(key, fallback);
        return fallback;
      }
      final limited = (books: merged.take(60).toList(), error: null);
      _addToCache(key, limited);
      return limited;
    }

    final olLang = langRestrict == 'en' ? 'eng' : null;
    final results = await Future.wait([
      _searchGoogle(effectiveQuery, maxResults: 40, langRestrict: langRestrict == 'it' ? 'it' : langRestrict),
      _searchOpenLibrary(query, maxResults: 40, lang: olLang, searchType: searchType),
    ]);
    final googleResult = results[0];
    final olResult = results[1];

    if (googleResult.error != null && googleResult.books.isEmpty) {
      if (olResult.error == null) _addToCache(key, olResult);
      return olResult;
    }

    final seenIds = <String>{};
    final seenTitles = <String>{};
    final merged = <Book>[];
    for (final b in googleResult.books) {
      if (seenIds.add(b.id)) {
        seenTitles.add('${b.title.toLowerCase()}|${b.authors.toLowerCase()}');
        merged.add(b);
      }
    }
    // SEMPRE include Open Library (autori emergenti)
    for (final b in olResult.books) {
      if (seenIds.add(b.id)) {
        final titleKey = '${b.title.toLowerCase()}|${b.authors.toLowerCase()}';
        if (seenTitles.add(titleKey)) merged.add(b);
      }
    }
    final result = (books: merged.take(60).toList(), error: null);
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
      _searchOpenLibrary(query, maxResults: 40, searchType: searchType),
    ]);
    final googleResult = results[0];
    final olResult = results[1];

    if (googleResult.error != null && googleResult.books.isEmpty) {
      if (olResult.error == null) _addToCache(key, olResult);
      return olResult;
    }

    final seenIds = <String>{};
    final seenTitles = <String>{};
    final merged = <Book>[];
    for (final b in googleResult.books) {
      if (seenIds.add(b.id)) {
        seenTitles.add('${b.title.toLowerCase()}|${b.authors.toLowerCase()}');
        merged.add(b);
      }
    }
    // SEMPRE include Open Library (autori emergenti/indie)
    for (final b in olResult.books) {
      if (seenIds.add(b.id)) {
        final titleKey = '${b.title.toLowerCase()}|${b.authors.toLowerCase()}';
        if (seenTitles.add(titleKey)) merged.add(b);
      }
    }
    final result = (books: merged.take(60).toList(), error: null);
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
      final res = await retryWithBackoff(
        () => http.get(uri).timeout(const Duration(seconds: 7)),
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 500),
      );
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

  /// Cerca nel catalogo OPAC SBN (Servizio Bibliotecario Nazionale italiano).
  /// Indicizza TUTTI i libri pubblicati in Italia, inclusi piccoli editori
  /// e autori emergenti/self-published con ISBN.
  Future<({List<Book> books, String? error})> _searchSbn(
      String query, {int maxResults = 20}) async {
    try {
      final encoded = Uri.encodeQueryComponent(query.trim());
      // L'API OPAC SBN usa il formato SRU/OpenSearch
      final url = '$_sbnBase?any=$encoded&rows=$maxResults&channel=OPAC_MOBILE';
      final res = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        return (books: <Book>[], error: null); // Fallimento silenzioso, non blocca
      }
      final data = jsonDecode(res.body);
      final records = (data['briefRecords'] ?? data['records'] ?? []) as List;
      if (records.isEmpty) return (books: <Book>[], error: null);

      final books = <Book>[];
      for (final r in records) {
        try {
          final title = (r['title'] ?? r['titolo'] ?? '') as String;
          final authors = (r['author'] ?? r['autore'] ?? 'Autore sconosciuto') as String;
          if (title.isEmpty) continue;
          final bid = r['bid'] ?? r['id'] ?? '';
          books.add(Book(
            id: 'sbn_$bid',
            title: title.replaceAll(RegExp(r'\s*/\s*$'), '').trim(),
            authors: authors.replaceAll(RegExp(r'\s*/\s*$'), '').trim(),
            publisher: r['publisher'] as String?,
            publishedDate: r['date'] as String?,
            isbn: r['isbn'] as String?,
            language: 'it',
            coverUrl: r['coverUrl'] as String?,
          ));
        } catch (_) {
          // Record malformato, skip
        }
      }
      return (books: books, error: null);
    } on TimeoutException {
      return (books: <Book>[], error: null); // Non blocca la ricerca principale
    } catch (e) {
      return (books: <Book>[], error: null); // Fallimento silenzioso
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
