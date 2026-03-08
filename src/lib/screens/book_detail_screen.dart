import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/book.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';
import 'write_review_screen.dart';
import '../config/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _loadReview();
    _loadDescriptionIfNeeded();
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
    if (uid == null) return;
    final r = await DbHelper().getReviewForBook(uid, widget.book.id);
    if (mounted) setState(() { _review = r; _loading = false; });
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

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina Recensione'),
        content: const Text('Sei sicuro di voler eliminare questa recensione?'),
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
      await DbHelper().deleteReview(_review!.id!);
      if (mounted) setState(() => _review = null);
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
            // Pulsante Anteprima Google Books
            if (book.previewLink != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
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
                      ? 'Apri su Open Library'
                      : 'Anteprima su Google Books'),
                ),
              ),
            ],
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
                          label: const Text('Scrivi la tua recensione'),
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
