import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/public_review.dart';
import '../services/supabase_service.dart';
import '../widgets/star_rating.dart';

class CommunityReviewDetailScreen extends StatefulWidget {
  final PublicReview review;
  const CommunityReviewDetailScreen({super.key, required this.review});

  @override
  State<CommunityReviewDetailScreen> createState() =>
      _CommunityReviewDetailScreenState();
}

class _CommunityReviewDetailScreenState
    extends State<CommunityReviewDetailScreen> {
  late PublicReview _review;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  Future<void> _toggleLike() async {
    await SupabaseService().toggleLike(_review);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(title: const Text('Recensione')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Libro
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_review.bookCoverUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _review.bookCoverUrl!,
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _coverPlaceholder(),
                        ),
                      )
                    else
                      _coverPlaceholder(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_review.bookTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(_review.bookAuthor,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 13)),
                          if (_review.bookPublisher != null ||
                              _review.bookYear != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (_review.bookPublisher != null)
                                  _review.bookPublisher!,
                                if (_review.bookYear != null) _review.bookYear!,
                              ].join(' · '),
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                          if (_review.bookGenre != null) ...[
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(_review.bookGenre!,
                                  style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  const Color(0xFF1A5276).withOpacity(0.1),
                              labelStyle:
                                  const TextStyle(color: Color(0xFF1A5276)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Recensore + valutazione
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFF1A5276).withOpacity(0.15),
                          child: Text(
                            _review.username.isNotEmpty
                                ? _review.username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Color(0xFF1A5276),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_review.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(_formatDate(_review.createdAt),
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StarRatingDisplay(rating: _review.rating, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      ['', 'Pessimo', 'Scarso', 'Nella media', 'Buono',
                          'Eccellente'][_review.rating],
                      style: const TextStyle(
                          color: Color(0xFFFFB300),
                          fontWeight: FontWeight.w500),
                    ),
                    if (_review.readDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Letto il ${_review.readDate}',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Testo recensione
            if (_review.reviewTitle != null || _review.reviewBody != null) ...[
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_review.reviewTitle != null) ...[
                        Text(_review.reviewTitle!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                      ],
                      if (_review.reviewBody != null)
                        Text(_review.reviewBody!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            // Like button
            Center(
              child: OutlinedButton.icon(
                onPressed: _toggleLike,
                icon: Icon(
                  _review.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _review.isLikedByMe
                      ? Colors.red
                      : const Color(0xFF1A5276),
                ),
                label: Text(
                  '${_review.likesCount} Mi piace',
                  style: TextStyle(
                    color: _review.isLikedByMe
                        ? Colors.red
                        : const Color(0xFF1A5276),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _review.isLikedByMe
                        ? Colors.red
                        : const Color(0xFF1A5276),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFD6EAF8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book,
          color: Color(0xFF1A5276), size: 32),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
