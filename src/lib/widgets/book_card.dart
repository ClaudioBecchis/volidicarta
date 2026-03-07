import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onSelectRead; // pulsante diretto "Ho letto"
  final bool hasReview;
  final bool inWishlist;
  final VoidCallback? onWishlistToggle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onSelectRead,
    this.hasReview = false,
    this.inWishlist = false,
    this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Copertina
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 56,
                  height: 80,
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
              const SizedBox(width: 12),
              // Info libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasReview)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.check_circle,
                                color: Color(0xFF1A5276), size: 18),
                          ),
                        if (onWishlistToggle != null)
                          GestureDetector(
                            onTap: onWishlistToggle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                inWishlist
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: inWishlist
                                    ? const Color(0xFFFFB300)
                                    : Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authors,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.publisher != null || book.publishedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          [
                            if (book.publisher != null) book.publisher!,
                            if (book.publishedDate != null)
                              book.publishedDate!.length >= 4
                                  ? book.publishedDate!.substring(0, 4)
                                  : book.publishedDate!,
                          ].join(' · '),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ),
                    // Pulsante diretto "Ho letto questo libro"
                    if (onSelectRead != null) ...[
                      const SizedBox(height: 8),
                      hasReview
                          ? OutlinedButton.icon(
                              onPressed: onSelectRead,
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Modifica recensione',
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A5276),
                                side: const BorderSide(
                                    color: Color(0xFF1A5276)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: onSelectRead,
                              icon: const Icon(Icons.check, size: 14),
                              label: const Text('Ho letto questo libro',
                                  style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                    ],
                  ],
                ),
              ),
              // Freccia dettaglio
              if (onSelectRead == null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFD6EAF8),
        child: const Center(
          child: Icon(Icons.menu_book, color: Color(0xFF1A5276), size: 28),
        ),
      );
}
