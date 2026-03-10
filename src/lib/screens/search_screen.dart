import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/review.dart';
import '../models/wishlist_book.dart';
import '../services/book_api_service.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';
import 'write_review_screen.dart';
import '../l10n/app_strings.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _historyKey = 'search_history';
  static const _historyMax = 15;

  final _ctrl = TextEditingController();
  final _api = BookApiService();
  List<Book> _results = [];
  String? _error;
  bool _loading = false;
  bool _searched = false;
  String _langFilter = 'it'; // 'it', 'en', 'all'
  String _searchType = 'all'; // 'all', 'intitle', 'inauthor'
  Map<String, Review> _reviewedMap = {}; // bookId → Review
  Set<String> _wishlistIds = {}; // bookId → in wishlist
  List<String> _history = [];
  List<String> _suggestions = [];
  Timer? _suggestTimer;

  @override
  void initState() {
    super.initState();
    _loadReviewed();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw != null && mounted) {
        setState(() => _history = List<String>.from(jsonDecode(raw)));
      }
    } catch (_) {}
  }

  Future<void> _addToHistory(String query) async {
    if (query.isEmpty) return;
    final updated = [query, ..._history.where((h) => h != query)]
        .take(_historyMax)
        .toList();
    if (mounted) setState(() => _history = updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(updated));
    } catch (_) {}
  }

  Future<void> _removeFromHistory(int index) async {
    final updated = List<String>.from(_history)..removeAt(index);
    if (mounted) setState(() => _history = updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(updated));
    } catch (_) {}
  }

  Future<void> _clearHistory() async {
    if (mounted) setState(() => _history = []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }

  Future<void> _loadReviewed() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    try {
      final reviews = await DbHelper().getReviewsByUser(uid);
      final wishlist = await DbHelper().getWishlist(uid);
      if (mounted) {
        setState(() {
          _reviewedMap = {for (final r in reviews) r.bookId: r};
          _wishlistIds = {for (final w in wishlist) w.bookId};
        });
      }
    } catch (e) {
      debugPrint('SearchScreen load error: $e');
    }
  }

  Future<void> _search([String? overrideQuery]) async {
    final q = (overrideQuery ?? _ctrl.text).trim();
    if (q.isEmpty) return;
    if (overrideQuery != null) {
      _ctrl.text = overrideQuery;
    }
    setState(() { _loading = true; _searched = true; _error = null; });
    final res = _langFilter == 'all'
        ? await _api.searchAll(q, searchType: _searchType)
        : await _api.search(q, langRestrict: _langFilter, searchType: _searchType);
    if (mounted) {
      setState(() { _results = res.books; _error = res.error; _loading = false; });
      if (res.books.isNotEmpty || res.error == null) _addToHistory(q);
    }
  }

  Future<void> _toggleWishlist(Book book) async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final inWish = _wishlistIds.contains(book.id);
    try {
      if (inWish) {
        await DbHelper().removeFromWishlist(uid, book.id);
        if (mounted) setState(() => _wishlistIds.remove(book.id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rimosso dalla lista "Da leggere"'),
                  duration: Duration(seconds: 2)));
        }
      } else {
        final wb = WishlistBook(
          userId: uid,
          bookId: book.id,
          bookTitle: book.title,
          bookAuthor: book.authors,
          bookCoverUrl: book.coverUrl,
          bookPublisher: book.publisher,
          bookYear: book.publishedDate != null && book.publishedDate!.length >= 4
              ? book.publishedDate!.substring(0, 4)
              : book.publishedDate,
          addedAt: DateTime.now().toIso8601String(),
        );
        await DbHelper().addToWishlist(wb);
        if (mounted) setState(() => _wishlistIds.add(book.id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aggiunto a "Da leggere" 🔖'),
                  duration: Duration(seconds: 2)));
        }
      }
    } catch (e) {
      debugPrint('Wishlist toggle error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore. Riprova.'),
                duration: Duration(seconds: 2)));
      }
    }
  }

  Future<void> _selectBook(Book book) async {
    final existing = _reviewedMap[book.id];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(book: book, existing: existing),
      ),
    );
    _loadReviewed();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _suggestTimer?.cancel();
    if (value.trim().length < 3 || _searchType == 'all') {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    _suggestTimer = Timer(const Duration(milliseconds: 350), () => _fetchSuggestions(value.trim()));
  }

  Future<void> _fetchSuggestions(String q) async {
    try {
      List<String> results = [];
      if (_searchType == 'inauthor') {
        final url = 'https://openlibrary.org/search/authors.json?q=${Uri.encodeQueryComponent(q)}&limit=6';
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final docs = data['docs'] as List? ?? [];
          results = docs.map((d) => d['name'] as String? ?? '').where((n) => n.isNotEmpty).toList();
        }
      } else if (_searchType == 'intitle') {
        final url = 'https://www.googleapis.com/books/v1/volumes?q=intitle:${Uri.encodeQueryComponent(q)}&maxResults=6&printType=books&fields=items(volumeInfo/title)';
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final items = data['items'] as List? ?? [];
          final seen = <String>{};
          for (final item in items) {
            final title = item['volumeInfo']?['title'] as String? ?? '';
            if (title.isNotEmpty && seen.add(title)) results.add(title);
          }
        }
      }
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {}
  }

  @override
  void dispose() {
    _suggestTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.search),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: _searchType == 'inauthor'
                    ? 'Es: Baricco, Umberto Eco, Calvino...'
                    : _searchType == 'intitle'
                        ? 'Es: Harry Potter, Il nome della rosa...'
                        : s.searchBookHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() { _results = []; _searched = false; _error = null; });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) {
                setState(() => _suggestions = []);
                _search();
              },
              onChanged: _onQueryChanged,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    leading: Icon(
                      _searchType == 'inauthor' ? Icons.person_outline : Icons.book_outlined,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                    title: Text(_suggestions[i], style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      final selected = _suggestions[i];
                      _ctrl.text = selected;
                      setState(() => _suggestions = []);
                      _search(selected);
                    },
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                for (final chip in [
                  ('Tutto', 'all'),
                  ('Titolo', 'intitle'),
                  ('Autore', 'inauthor'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(chip.$1),
                      selected: _searchType == chip.$2,
                      onSelected: (_) => setState(() { _searchType = chip.$2; _suggestions = []; }),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                for (final chip in [
                  ('🇮🇹 ITA', 'it'),
                  ('🇬🇧 ENG', 'en'),
                  ('🌐 Tutti', 'all'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(chip.$1),
                      selected: _langFilter == chip.$2,
                      onSelected: (_) => setState(() => _langFilter = chip.$2),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _search,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search),
                label: const Text('Cerca'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults()),
          // Attribution richiesta dai Google Books API Terms of Service
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Powered by ',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                const Text('Google',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w600)),
                Text(' · Open Library',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searched) {
      if (_history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _searchType == 'inauthor'
                    ? 'Scrivi il nome dell\'autore'
                    : _searchType == 'intitle'
                        ? 'Scrivi il titolo del libro'
                        : 'Cerca un libro per titolo o autore',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Text(
                _searchType == 'inauthor'
                    ? 'Es: Baricco · Umberto Eco · Calvino'
                    : _searchType == 'intitle'
                        ? 'Es: Harry Potter · Il nome della rosa'
                        : 'Es: Baricco · Harry Potter · 9788804668336',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text('Fonte: Google Books (Amazon, Feltrinelli, IBS...)',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.history, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('Ricerche recenti',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                TextButton(
                  onPressed: _clearHistory,
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Cancella tutto',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                leading: const Icon(Icons.history, color: Colors.grey, size: 20),
                title: Text(_history[i], style: const TextStyle(fontSize: 14)),
                trailing: IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                  onPressed: () => _removeFromHistory(i),
                  tooltip: 'Rimuovi',
                ),
                onTap: () => _search(_history[i]),
              ),
            ),
          ),
        ],
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.find_in_page,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Nessun risultato trovato',
                style: TextStyle(color: Colors.grey.shade500)),
            if (_langFilter != 'all') ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() => _langFilter = 'all');
                  _search();
                },
                child: const Text('Cerca in tutte le lingue'),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final book = _results[i];
        return BookCard(
          book: book,
          hasReview: _reviewedMap.containsKey(book.id),
          inWishlist: _wishlistIds.contains(book.id),
          onWishlistToggle: () => _toggleWishlist(book),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: book)),
            );
            _loadReviewed();
          },
          onSelectRead: () => _selectBook(book),
        );
      },
    );
  }
}
