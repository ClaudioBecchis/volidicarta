class Book {
  final String id;
  final String title;
  final String authors;
  final String? description;
  final String? coverUrl;
  final String? publisher;
  final String? publishedDate;
  final String? isbn;
  final int? pageCount;
  final String? categories;
  final String? previewLink;   // link anteprima Google Books
  final String? coverLargeUrl; // copertina alta risoluzione

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.coverUrl,
    this.publisher,
    this.publishedDate,
    this.isbn,
    this.pageCount,
    this.categories,
    this.previewLink,
    this.coverLargeUrl,
  });

  factory Book.fromGoogleApi(Map<String, dynamic> json) {
    final info = json['volumeInfo'] ?? {};
    final imageLinks = info['imageLinks'] ?? {};
    final identifiers = (info['industryIdentifiers'] as List?)
            ?.firstWhere(
              (i) => i['type'] == 'ISBN_13',
              orElse: () => (info['industryIdentifiers'] as List?)?.firstOrNull ?? {},
            ) ??
        {};

    String? toHttps(String? url) =>
        url?.replaceFirst('http://', 'https://');

    final cover = toHttps(imageLinks['thumbnail'] as String?);
    final coverLarge = toHttps(
        imageLinks['extraLarge'] as String? ??
        imageLinks['large'] as String? ??
        imageLinks['medium'] as String? ??
        imageLinks['thumbnail'] as String?);
    final previewLink = toHttps(json['volumeInfo']?['previewLink'] as String?
        ?? json['accessInfo']?['webReaderLink'] as String?);

    return Book(
      id: json['id'] ?? '',
      title: info['title'] ?? 'Titolo sconosciuto',
      authors: (info['authors'] as List?)?.join(', ') ?? 'Autore sconosciuto',
      description: info['description'],
      coverUrl: cover,
      coverLargeUrl: coverLarge,
      publisher: info['publisher'],
      publishedDate: info['publishedDate'],
      isbn: identifiers['identifier'],
      pageCount: info['pageCount'],
      categories: (info['categories'] as List?)?.join(', '),
      previewLink: previewLink,
    );
  }
}
