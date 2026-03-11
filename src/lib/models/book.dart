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
  final String? previewLink;    // link anteprima Google Books
  final String? pdfDownloadLink; // link PDF gratuito (solo dominio pubblico)
  final String? coverLargeUrl;  // copertina alta risoluzione
  final String? language;       // codice lingua (es. 'it', 'en')

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
    this.pdfDownloadLink,
    this.coverLargeUrl,
    this.language,
  });

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final String? cover = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : null;
    final String? coverLarge = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
        : null;
    final key = (json['key'] as String? ?? '').replaceAll('/', '_');
    final isbns = json['isbn'] as List?;
    final isbn13 = isbns?.cast<String>().firstWhere(
          (s) => s.length == 13,
          orElse: () => isbns.isNotEmpty ? isbns.first as String : '',
        );
    final authors = (json['author_name'] as List?)?.cast<String>().join(', ')
        ?? 'Autore sconosciuto';
    final subjects = (json['subject'] as List?)?.cast<String>().take(3).join(', ');
    final year = json['first_publish_year']?.toString();

    return Book(
      id: 'ol_$key',
      title: json['title'] ?? 'Titolo sconosciuto',
      authors: authors,
      coverUrl: cover,
      coverLargeUrl: coverLarge,
      publisher: (json['publisher'] as List?)?.cast<String>().firstOrNull,
      publishedDate: year,
      isbn: isbn13,
      pageCount: json['number_of_pages_median'],
      categories: subjects,
      previewLink: coverId != null
          ? 'https://openlibrary.org${json['key']}'
          : null,
    );
  }

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

    final accessInfo = json['accessInfo'] ?? {};
    final pdfInfo = accessInfo['pdf'] ?? {};
    final pdfAvailable = pdfInfo['isAvailable'] == true;
    final pdfDownloadLink = pdfAvailable
        ? toHttps(pdfInfo['downloadLink'] as String?
            ?? pdfInfo['acsTokenLink'] as String?)
        : null;

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
      pdfDownloadLink: pdfDownloadLink,
      language: info['language'] as String?,
    );
  }
}
