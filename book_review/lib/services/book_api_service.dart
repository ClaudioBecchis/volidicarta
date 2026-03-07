import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  // Cerca libri per titolo, autore, ISBN, ecc.
  // Funziona con Amazon, Feltrinelli, IBS, Mondadori, ecc.
  // (tutti i libri su Google Books)
  Future<List<Book>> search(String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
        '$_base?q=$encoded&maxResults=$maxResults&langRestrict=it&printType=books');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      final items = data['items'] as List?;
      if (items == null) return [];
      return items.map((j) => Book.fromGoogleApi(j)).toList();
    } catch (_) {
      return [];
    }
  }

  // Cerca senza limitare la lingua
  Future<List<Book>> searchAll(String query, {int maxResults = 20}) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
        '$_base?q=$encoded&maxResults=$maxResults&printType=books');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      final items = data['items'] as List?;
      if (items == null) return [];
      return items.map((j) => Book.fromGoogleApi(j)).toList();
    } catch (_) {
      return [];
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
