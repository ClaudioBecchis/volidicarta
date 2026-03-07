import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';
import 'write_review_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Review? _review;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final r = await DbHelper().getReviewForBook(uid, widget.book.id);
    if (mounted) setState(() { _review = r; _loading = false; });
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
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(
        title: const Text('Dettaglio Libro'),
        actions: [
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
                                placeholder: (_, __) => _placeholder(),
                                errorWidget: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
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
            // Descrizione
            if (book.description != null) ...[
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
                      _ExpandableText(text: book.description!),
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

  Widget _placeholder() => Container(
        color: const Color(0xFFD6EAF8),
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
      color: const Color(0xFFEAF4FC),
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
            if (review.readDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Letto il ${review.readDate}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
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
