import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../models/wishlist_book.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import 'write_review_screen.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistBook> _books = [];
  List<WishlistBook> _filtered = [];
  bool _loading = true;
  String _sortBy = 'date';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    try {
      final books = await DbHelper().getWishlist(uid);
      if (mounted) {
        setState(() { _books = books; _loading = false; });
        _applyFilter();
      }
    } catch (e) {
      debugPrint('WishlistScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    final result = _books.where((b) =>
      b.bookTitle.toLowerCase().contains(q) ||
      b.bookAuthor.toLowerCase().contains(q)
    ).toList();
    result.sort((a, b) {
      switch (_sortBy) {
        case 'title':  return a.bookTitle.compareTo(b.bookTitle);
        case 'author': return a.bookAuthor.compareTo(b.bookAuthor);
        default:       return b.addedAt.compareTo(a.addedAt);
      }
    });
    if (mounted) setState(() => _filtered = result);
  }

  Future<void> _remove(WishlistBook book) async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    try {
      await DbHelper().removeFromWishlist(uid, book.bookId);
      if (mounted) {
        setState(() => _books.removeWhere((b) => b.bookId == book.bookId));
        _applyFilter();
      }
    } catch (e) {
      debugPrint('Remove wishlist error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore durante la rimozione')));
      }
    }
  }

  Future<void> _startReview(WishlistBook wb) async {
    // Crea un Book a partire da WishlistBook per aprire WriteReviewScreen
    final book = Book(
      id: wb.bookId,
      title: wb.bookTitle,
      authors: wb.bookAuthor,
      coverUrl: wb.bookCoverUrl,
      publisher: wb.bookPublisher,
      publishedDate: wb.bookYear,
      categories: wb.bookGenre,
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WriteReviewScreen(book: book)),
    );
    if (result == true) {
      // Dopo aver scritto la recensione, offri di rimuoverlo dalla wishlist
      if (!mounted) return;
      final remove = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Recensione salvata!'),
          content: Text('Vuoi rimuovere "${wb.bookTitle}" dalla lista "Da leggere"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No, tienilo')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sì, rimuovi')),
          ],
        ),
      );
      if (remove == true) await _remove(wb);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: Text(S.of(context).toRead),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordina',
            onSelected: (v) { _sortBy = v; _applyFilter(); },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'date',   child: Text('Per data aggiunta')),
              PopupMenuItem(value: 'title',  child: Text('Per titolo')),
              PopupMenuItem(value: 'author', child: Text('Per autore')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('${_filtered.length} libri',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cerca titolo o autore…',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () { _searchCtrl.clear(); _applyFilter(); },
                      ),
                filled: true,
                fillColor: Colors.white12,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _buildEmpty()
              : _filtered.isEmpty
                  ? Center(
                      child: Text('Nessun risultato',
                          style: TextStyle(color: Colors.grey.shade500)),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _WishCard(
                          book: _filtered[i],
                          onReview: () => _startReview(_filtered[i]),
                          onRemove: () => _remove(_filtered[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Nessun libro nella lista',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Cerca un libro e premi il segnalibro\nper aggiungerlo qui',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  final WishlistBook book;
  final VoidCallback onReview;
  final VoidCallback onRemove;

  const _WishCard({required this.book, required this.onReview, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Copertina
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: book.bookCoverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.bookCoverUrl!,
                      width: 56,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.bookTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(book.bookAuthor,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (book.bookYear != null) ...[
                    const SizedBox(height: 2),
                    Text(book.bookYear!,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12)),
                  ],
                  if (book.notes != null && book.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(book.notes!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.amber.shade800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.rate_review_outlined, size: 16),
                          label: const Text('Recensisci', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade300),
                        onPressed: onRemove,
                        tooltip: 'Rimuovi dalla lista',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 56,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.menu_book_outlined,
            color: Colors.grey.shade400, size: 28),
      );
}
