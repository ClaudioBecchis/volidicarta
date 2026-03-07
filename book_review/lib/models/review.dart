class Review {
  final int? id;
  final int userId;
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
    this.readDate,
    required this.createdAt,
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
        'read_date': readDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'],
        userId: map['user_id'],
        bookId: map['book_id'],
        bookTitle: map['book_title'],
        bookAuthor: map['book_author'],
        bookCoverUrl: map['book_cover_url'],
        bookPublisher: map['book_publisher'],
        bookYear: map['book_year'],
        bookGenre: map['book_genre'],
        rating: map['rating'],
        reviewTitle: map['review_title'],
        reviewBody: map['review_body'],
        readDate: map['read_date'],
        createdAt: map['created_at'],
        updatedAt: map['updated_at'],
      );

  Review copyWith({
    int? rating,
    String? reviewTitle,
    String? reviewBody,
    String? readDate,
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
        readDate: readDate ?? this.readDate,
        createdAt: createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
}
