class Review {
  final int? id;
  final String userId; // UUID Supabase
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
  final String? startDate;
  final String? endDate;
  final String? createdAt;
  final String updatedAt;

  Review({
    this.id,
    required this.userId,
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
    this.startDate,
    this.endDate,
    this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
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
        'start_date': startDate,
        'end_date': endDate,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'updated_at': updatedAt,
      };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as int?,
        userId: map['user_id'] as String,
        bookId: map['book_id'] as String,
        bookTitle: map['book_title'] as String,
        bookAuthor: map['book_author'] as String,
        bookCoverUrl: map['book_cover_url'] as String?,
        bookPublisher: map['book_publisher'] as String?,
        bookYear: map['book_year'] as String?,
        bookGenre: map['book_genre'] as String?,
        rating: map['rating'] as int,
        reviewTitle: map['review_title'] as String?,
        reviewBody: map['review_body'] as String?,
        startDate: map['start_date'] as String?,
        endDate: map['end_date'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String,
      );

  Review copyWith({
    int? rating,
    String? reviewTitle,
    String? reviewBody,
    String? startDate,
    String? endDate,
    String? bookGenre,
  }) =>
      Review(
        id: id,
        userId: userId,
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookCoverUrl: bookCoverUrl,
        bookPublisher: bookPublisher,
        bookYear: bookYear,
        bookGenre: bookGenre ?? this.bookGenre,
        rating: rating ?? this.rating,
        reviewTitle: reviewTitle ?? this.reviewTitle,
        reviewBody: reviewBody ?? this.reviewBody,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        createdAt: createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
}
