import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book.dart';
import '../models/review.dart';
import '../models/wishlist_book.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../services/review_sync_service.dart';
import '../widgets/star_rating.dart';
import 'write_review_screen.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Review? _review;
  bool _loading = true;
  String? _fetchedDescription;
  bool _inWishlist = false;

  @override
  void initState() {
    super.initState();
    _loadReview();
    _loadDescriptionIfNeeded();
    _loadWishlistState();
  }

  Future<void> _loadWishlistState() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final inW = await DbHelper().isInWishlist(uid, widget.book.id);
    if (mounted) setState(() => _inWishlist = inW);
  }

  Future<void> _loadDescriptionIfNeeded() async {
    final book = widget.book;
    if (book.description != null) return;
    // Open Library: recupera descrizione dalla Works API
    if (book.id.startsWith('ol_') && book.previewLink != null) {
      try {
        final worksUrl = '${book.previewLink}.json';
        final res = await http.get(Uri.parse(worksUrl))
            .timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          String? desc;
          final raw = data['description'];
          if (raw is String) { desc = raw; }
          else if (raw is Map) { desc = raw['value'] as String?; }
          if (desc != null && mounted) {
            setState(() { _fetchedDescription = desc; });
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _loadReview() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) { if (mounted) setState(() => _loading = false); return; }
    try {
      final r = await DbHelper().getReviewForBook(uid, widget.book.id);
      if (mounted) setState(() { _review = r; _loading = false; });
    } catch (e) {
      debugPrint('BookDetail load review error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCoverFullscreen(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 80),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToWishlist() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accedi per aggiungere alla lista "Da leggere"')));
      return;
    }
    final book = widget.book;
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
      bookGenre: book.categories,
      addedAt: DateTime.now().toIso8601String(),
    );
    await DbHelper().addToWishlist(wb);
    if (mounted) {
      setState(() => _inWishlist = true);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aggiunto a "Da leggere" 🔖'),
              duration: Duration(seconds: 2)));
    }
  }

  Future<void> _removeFromWishlist() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    await DbHelper().removeFromWishlist(uid, widget.book.id);
    if (mounted) {
      setState(() => _inWishlist = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rimosso dalla lista "Da leggere"'),
              duration: Duration(seconds: 2)));
    }
  }

  void _showBuyOptions() {
    final book = widget.book;
    // ISBN è la ricerca più precisa; fallback al solo titolo
    final searchTerm = book.isbn != null && book.isbn!.isNotEmpty
        ? book.isbn!
        : book.title;
    final q = Uri.encodeComponent(searchTerm);

    final stores = [
      (
        name: 'Amazon',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFFFF9900),
        url: 'https://www.amazon.it/s?k=$q&i=stripbooks',
      ),
      (
        name: 'Feltrinelli',
        icon: Icons.store_outlined,
        color: const Color(0xFFE30613),
        url: 'https://www.lafeltrinelli.it/search/?query=$q&filterProduct_type_description=Libri',
      ),
      (
        name: 'IBS',
        icon: Icons.book_outlined,
        color: const Color(0xFF0055A5),
        url: 'https://www.ibs.it/search/?ts=as&query=$q',
      ),
      (
        name: 'Unilibro',
        icon: Icons.local_library_outlined,
        color: const Color(0xFF2E7D32),
        url: 'https://www.unilibro.it/libri/ricerca?cerca=$q',
      ),
      (
        name: 'Mondadori Store',
        icon: Icons.storefront_outlined,
        color: const Color(0xFF6B1FA2),
        url: 'https://www.mondadoristore.it/search?q=$q',
      ),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Acquista "${book.title}"',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 12),
              ...stores.map((s) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: s.color.withValues(alpha: 0.12),
                      child: Icon(s.icon, color: s.color, size: 20),
                    ),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final uri = Uri.parse(s.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                      if (!mounted) return;
                      if (!_inWishlist) {
                        final add = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Aggiunto alla lista?'),
                            content: const Text(
                                'Vuoi aggiungere il libro alla lista "Da leggere"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('No')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sì, aggiungi')),
                            ],
                          ),
                        );
                        if (add == true && mounted) await _addToWishlist();
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina Recensione'),
        content: Text(S.of(context).deleteReviewConfirm),
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
    if (confirm == true && _review != null) {
      try {
        final r = _review!;
        await DbHelper().deleteReview(r.id!);
        ReviewSyncService().delete(r.userId, r.bookId);
        if (mounted) setState(() => _review = null);
      } catch (e) {
        debugPrint('Delete review error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Errore durante l\'eliminazione')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: const Text('Dettaglio Libro'),
        actions: [
          IconButton(
            icon: Icon(_inWishlist ? Icons.bookmark : Icons.bookmark_border),
            tooltip: _inWishlist ? 'Rimuovi da "Da leggere"' : 'Aggiungi a "Da leggere"',
            onPressed: _inWishlist ? _removeFromWishlist : _addToWishlist,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Condividi',
            onPressed: () {
              final text = '📚 ${book.title} — ${book.authors}';
              Share.share(text);
            },
          ),
          if (_review != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteReview,
              tooltip: 'Elimina recensione',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Copertina + info base
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 90,
                        height: 130,
                        child: book.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: book.coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _placeholder(context),
                                errorWidget: (_, __, ___) => _placeholder(context),
                              )
                            : _placeholder(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(book.authors,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 14)),
                          if (book.publisher != null) ...[
                            const SizedBox(height: 4),
                            Text(book.publisher!,
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 12)),
                          ],
                          if (book.publishedDate != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              book.publishedDate!.length >= 4
                                  ? book.publishedDate!.substring(0, 4)
                                  : book.publishedDate!,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                          if (book.pageCount != null) ...[
                            const SizedBox(height: 2),
                            Text('${book.pageCount} pagine',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 12)),
                          ],
                          if (book.isbn != null) ...[
                            const SizedBox(height: 2),
                            Text('ISBN: ${book.isbn}',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Anteprima copertina grande (se disponibile)
            if (book.coverLargeUrl != null) ...[
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onTap: () => _showCoverFullscreen(book.coverLargeUrl!),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CachedNetworkImage(
                        imageUrl: book.coverLargeUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const SizedBox(height: 220,
                            child: Center(child: CircularProgressIndicator())),
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Ingrandisci',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Pulsanti azioni
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showBuyOptions,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Acquista'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5276),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (book.previewLink != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(book.previewLink!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.preview_outlined),
                      label: Text(book.id.startsWith('ol_')
                          ? 'Open Library'
                          : 'Anteprima'),
                    ),
                  ),
                ],
              ],
            ),
            // Descrizione
            if (book.description != null || _fetchedDescription != null) ...[
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descrizione',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      _ExpandableText(text: book.description ?? _fetchedDescription!),
                    ],
                  ),
                ),
              ),
            ],
            // La mia recensione
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_review != null)
              _ReviewCard(
                review: _review!,
                onEdit: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteReviewScreen(
                          book: book, existing: _review),
                    ),
                  );
                  _loadReview();
                },
              )
            else
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          size: 48, color: Color(0xFF1A5276)),
                      const SizedBox(height: 8),
                      const Text(
                        'Non hai ancora recensito questo libro',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WriteReviewScreen(book: book),
                              ),
                            );
                            _loadReview();
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(S.of(context).writeYourReview),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext ctx) => Container(
        color: AppColors.chipBg(ctx),
        child: const Center(
          child: Icon(Icons.menu_book, color: Color(0xFF1A5276), size: 36),
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onEdit;

  const _ReviewCard({required this.review, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.chipBgLight(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review,
                    color: Color(0xFF1A5276), size: 20),
                const SizedBox(width: 8),
                const Text('La tua Recensione',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  tooltip: 'Modifica',
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            StarRatingDisplay(rating: review.rating, size: 24),
            if (review.reviewTitle != null &&
                review.reviewTitle!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(review.reviewTitle!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
            if (review.reviewBody != null &&
                review.reviewBody!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.reviewBody!,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
            if (review.startDate != null || review.endDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    review.startDate != null && review.endDate != null
                        ? '${review.startDate} → ${review.endDate}'
                        : review.endDate != null
                            ? 'Finito il ${review.endDate}'
                            : 'Iniziato il ${review.startDate}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : 4,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Mostra meno' : 'Leggi tutto',
              style: const TextStyle(color: Color(0xFF1A5276))),
        ),
      ],
    );
  }
}
