import 'package:flutter/material.dart';
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
  final _ctrl = TextEditingController();
  final _api = BookApiService();
  List<Book> _results = [];
  String? _error;
  bool _loading = false;
  bool _searched = false;
  String _langFilter = 'it'; // 'it', 'en', 'all'
  Map<String, Review> _reviewedMap = {}; // bookId → Review
  Set<String> _wishlistIds = {}; // bookId → in wishlist

  @override
  void initState() {
    super.initState();
    _loadReviewed();
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

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _searched = true; _error = null; });
    final res = _langFilter == 'all'
        ? await _api.searchAll(q)
        : await _api.search(q, langRestrict: _langFilter);
    if (mounted) setState(() { _results = res.books; _error = res.error; _loading = false; });
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

  @override
  void dispose() {
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
                hintText: s.searchBookHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          setState(
                              () { _results = []; _searched = false; });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _search(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_searched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Cerca un libro per titolo o autore',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Fonte: Google Books (Amazon, Feltrinelli, IBS...)',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
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
