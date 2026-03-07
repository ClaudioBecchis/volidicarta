class PublicReview {
  final String id;
  final String userId;
  final String username;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String? bookPublisher;
  final String? bookYear;
  final String? bookGenre;
  final int rating;
  final String? reviewTitle;
  final String? reviewBody;
  final String? readDate;
  final String createdAt;
  int likesCount;
  bool isLikedByMe;

  PublicReview({
    required this.id,
    required this.userId,
    required this.username,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    this.bookPublisher,
    this.bookYear,
    this.bookGenre,
    required this.rating,
    this.reviewTitle,
    this.reviewBody,
    this.readDate,
    required this.createdAt,
    this.likesCount = 0,
    this.isLikedByMe = false,
  });

  factory PublicReview.fromMap(Map<String, dynamic> m) {
    return PublicReview(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      username: m['username'] as String? ?? 'Utente',
      bookId: m['book_id'] as String,
      bookTitle: m['book_title'] as String,
      bookAuthor: m['book_author'] as String,
      bookCoverUrl: m['book_cover_url'] as String?,
      bookPublisher: m['book_publisher'] as String?,
      bookYear: m['book_year'] as String?,
      bookGenre: m['book_genre'] as String?,
      rating: (m['rating'] as num).toInt(),
      reviewTitle: m['review_title'] as String?,
      reviewBody: m['review_body'] as String?,
      readDate: m['read_date'] as String?,
      createdAt: m['created_at'] as String? ?? DateTime.now().toIso8601String(),
      likesCount: (m['likes_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'user_id': userId,
        'username': username,
        'book_id': bookId,
        'book_title': bookTitle,
        'book_author': bookAuthor,
        'book_cover_url': bookCoverUrl,
        'book_publisher': bookPublisher,
        'book_year': bookYear,
        'book_genre': bookGenre,
        'rating': rating,
        'review_title': reviewTitle,
        'review_body': reviewBody,
        'read_date': readDate,
      };
}
