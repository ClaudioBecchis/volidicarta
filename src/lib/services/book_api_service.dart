import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  // Cerca libri per titolo, autore, ISBN, ecc.
  // Funziona con Amazon, Feltrinelli, IBS, Mondadori, ecc.
  // (tutti i libri su Google Books)
  Future<({List<Book> books, String? error})> search(
      String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
        '$_base?q=$encoded&maxResults=$maxResults&langRestrict=it&printType=books');
    return _fetch(uri);
  }

  Future<({List<Book> books, String? error})> searchAll(
      String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return (books: <Book>[], error: null);
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
        '$_base?q=$encoded&maxResults=$maxResults&printType=books');
    return _fetch(uri);
  }

  Future<({List<Book> books, String? error})> _fetch(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
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
