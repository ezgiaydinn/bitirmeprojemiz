// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String thumbnailUrl;
  final String description;
  final List<String> categories;

  // Yeni eklenen alanlar
  final String? publisher;
  final String? publishedDate;
  final int? pageCount;
  final List<String>? industryIdentifiers;

  final double? averageRating;
  final int? ratingsCount;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
    required this.description,
    required this.categories,
    this.publisher,
    this.publishedDate,
    this.pageCount,
    this.industryIdentifiers,
    this.averageRating,
    this.ratingsCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final info = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};

    final cats =
        (info['categories'] as List<dynamic>?)?.cast<String>() ?? <String>[];

    // ISBN listesi
    final identifiers =
        (info['industryIdentifiers'] as List<dynamic>?)
            ?.map((e) => (e as Map<String, dynamic>)['identifier'] as String?)
            .whereType<String>()
            .toList();

    // Thumbnail HTTPS dönüşümü
    String thumb = (info['imageLinks']?['thumbnail'] as String?) ?? '';
    if (thumb.startsWith('http:')) {
      thumb = thumb.replaceFirst('http:', 'https:');
    }

    return Book(
      id: json['id'] as String,
      title: info['title'] as String? ?? '—',
      authors:
          (info['authors'] as List<dynamic>?)?.cast<String>() ??
          ['Bilinmeyen yazar'],
      thumbnailUrl: thumb,
      description: info['description'] as String? ?? 'Açıklama bulunamadı.',
      categories: cats,
      publisher: info['publisher'] as String?,
      publishedDate: info['publishedDate'] as String?,
      pageCount: info['pageCount'] as int?,
      industryIdentifiers: identifiers,
      averageRating: (info['averageRating'] as num?)?.toDouble(),
      ratingsCount: info['ratingsCount'] as int?,
    );
  }
}
