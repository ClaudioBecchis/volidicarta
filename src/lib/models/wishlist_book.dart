class WishlistBook {
  final int? id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String? bookPublisher;
  final String? bookYear;
  final String? bookGenre;
  final String? notes;
  final String addedAt;

  WishlistBook({
    this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    this.bookPublisher,
    this.bookYear,
    this.bookGenre,
    this.notes,
    required this.addedAt,
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
        'notes': notes,
        'added_at': addedAt,
      };

  factory WishlistBook.fromMap(Map<String, dynamic> map) => WishlistBook(
        id: map['id'] as int?,
        userId: map['user_id'] as String,
        bookId: map['book_id'] as String,
        bookTitle: map['book_title'] as String,
        bookAuthor: map['book_author'] as String,
        bookCoverUrl: map['book_cover_url'] as String?,
        bookPublisher: map['book_publisher'] as String?,
        bookYear: map['book_year'] as String?,
        bookGenre: map['book_genre'] as String?,
        notes: map['notes'] as String?,
        addedAt: map['added_at'] as String,
      );
}
