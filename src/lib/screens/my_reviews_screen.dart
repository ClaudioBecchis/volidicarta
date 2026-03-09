import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review.dart';
import '../models/book.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';
import 'book_detail_screen.dart';
import 'add_book_manual_screen.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

enum _GroupBy { none, author, genre }

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<Review> _reviews = [];
  List<Review> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  int _filterRating = 0;
  _GroupBy _groupBy = _GroupBy.none;
  Map<String, List<Review>>? _groupedCache;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    try {
      final reviews = await DbHelper().getReviewsByUser(uid);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
          _groupedCache = null;
        });
        _applyFilter();
      }
    } catch (e) {
      debugPrint('MyReviewsScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _reviews.where((r) {
        final matchText = q.isEmpty ||
            r.bookTitle.toLowerCase().contains(q) ||
            r.bookAuthor.toLowerCase().contains(q) ||
            (r.bookGenre?.toLowerCase().contains(q) ?? false) ||
            (r.reviewTitle?.toLowerCase().contains(q) ?? false) ||
            (r.reviewBody?.toLowerCase().contains(q) ?? false);
        final matchRating =
            _filterRating == 0 || r.rating == _filterRating;
        return matchText && matchRating;
      }).toList();
      _groupedCache = null;
    });
  }

  // Raggruppa la lista per chiave (memoizzata)
  Map<String, List<Review>> _grouped() {
    return _groupedCache ??= _buildGrouped();
  }

  Map<String, List<Review>> _buildGrouped() {
    final Map<String, List<Review>> map = {};
    for (final r in _filtered) {
      final key = _groupBy == _GroupBy.author
          ? r.bookAuthor
          : (r.bookGenre?.isNotEmpty == true ? r.bookGenre! : 'Senza genere');
      map.putIfAbsent(key, () => []).add(r);
    }
    // Ordina alfabeticamente
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.myReviewsFull),
        actions: [
          // Pulsante raggruppamento
          PopupMenuButton<_GroupBy>(
            icon: const Icon(Icons.sort),
            tooltip: s.groupBy,
            initialValue: _groupBy,
            onSelected: (v) => setState(() { _groupBy = v; _groupedCache = null; }),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _GroupBy.none,
                child: ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Tutti i libri'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: _GroupBy.author,
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Per Autore'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: _GroupBy.genre,
                child: ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Per Genere / Tipo'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          // Filtro stelle
          PopupMenuButton<int>(
            icon: const Icon(Icons.star_outline),
            tooltip: s.filterByStars,
            onSelected: (v) {
              setState(() => _filterRating = v);
              _applyFilter();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 0, child: Text(s.allStars)),
              for (int i = 5; i >= 1; i--)
                PopupMenuItem(
                  value: i,
                  child: Row(
                    children: [
                      StarRatingDisplay(rating: i, size: 16),
                      const SizedBox(width: 8),
                      Text('$i stelle'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddBookManualScreen()));
          _load();
        },
        icon: const Icon(Icons.add),
        label: Text(s.addBook),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra ricerca + chip filtri attivi
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cerca per titolo, autore, genere...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => _applyFilter(),
            ),
          ),
          // Chips filtri attivi
          if (_filterRating > 0 || _groupBy != _GroupBy.none)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (_filterRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarRatingDisplay(
                                rating: _filterRating, size: 14),
                            const SizedBox(width: 4),
                            Text('$_filterRating stelle'),
                          ],
                        ),
                        onDeleted: () {
                          setState(() => _filterRating = 0);
                          _applyFilter();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  if (_groupBy != _GroupBy.none)
                    Chip(
                      avatar: Icon(
                        _groupBy == _GroupBy.author
                            ? Icons.person_outline
                            : Icons.category_outlined,
                        size: 16,
                      ),
                      label: Text(
                        _groupBy == _GroupBy.author
                            ? 'Per Autore'
                            : 'Per Genere',
                      ),
                      onDeleted: () => setState(() => _groupBy = _GroupBy.none),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                ],
              ),
            ),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Non hai ancora recensito nessun libro',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            const SizedBox(height: 8),
            Text(S.of(context).searchOrAddManually,
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
          child: Text('Nessun risultato',
              style: TextStyle(color: Colors.grey.shade500)));
    }

    if (_groupBy == _GroupBy.none) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _ReviewTile(
          review: _filtered[i],
          onTap: () => _openDetail(_filtered[i]),
          onDelete: () => _deleteReview(_filtered[i]),
        ),
      );
    }

    // Vista raggruppata
    final groups = _grouped();
    final keys = groups.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        final items = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header gruppo
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5276).withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  Icon(
                    _groupBy == _GroupBy.author
                        ? Icons.person
                        : Icons.category,
                    color: const Color(0xFF1A5276),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      key,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A5276)),
                    ),
                  ),
                  Text(
                    '${items.length} ${items.length == 1 ? 'libro' : 'libri'}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            ...items.map((r) => _ReviewTile(
                  review: r,
                  onTap: () => _openDetail(r),
                  onDelete: () => _deleteReview(r),
                )),
          ],
        );
      },
    );
  }

  Future<void> _openDetail(Review r) async {
    final book = Book(
      id: r.bookId,
      title: r.bookTitle,
      authors: r.bookAuthor,
      coverUrl: r.bookCoverUrl,
      publisher: r.bookPublisher,
      publishedDate: r.bookYear,
      categories: r.bookGenre,
    );
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
    _load();
  }

  Future<void> _deleteReview(Review r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina Recensione'),
        content: const Text(
            'Sei sicuro di voler eliminare questa recensione?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Elimina')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await DbHelper().deleteReview(r.id!);
        _load();
      } catch (e) {
        debugPrint('Delete review error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Errore durante l\'eliminazione')));
        }
      }
    }
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReviewTile(
      {required this.review, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 56,
                  height: 80,
                  child: review.bookCoverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: review.bookCoverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholder(context),
                          errorWidget: (_, __, ___) => _placeholder(context),
                        )
                      : _placeholder(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.bookTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.bookAuthor,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (review.bookGenre != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1A5276).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          review.bookGenre!,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF1A5276)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    StarRatingDisplay(rating: review.rating, size: 18),
                    if (review.reviewTitle != null &&
                        review.reviewTitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        review.reviewTitle!,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (review.endDate != null || review.startDate != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        review.startDate != null && review.endDate != null
                            ? '${review.startDate} → ${review.endDate}'
                            : review.endDate != null
                                ? 'Finito: ${review.endDate}'
                                : 'Iniziato: ${review.startDate}',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Elimina',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext ctx) => Container(
        color: AppColors.chipBg(ctx),
        child: const Center(
          child: Icon(Icons.menu_book, color: Color(0xFF1A5276), size: 24),
        ),
      );
}
