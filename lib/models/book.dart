// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String thumbnailUrl;
  final String description;
  final String? publishedDate;    // artık nullable
  final double? averageRating;
  final int? ratingsCount;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
    required this.description,
    this.publishedDate,
    this.averageRating,
    this.ratingsCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final info = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};
    return Book(
      id: json['id'] as String,
      title: info['title'] as String? ?? '—',
      authors: (info['authors'] as List<dynamic>?)?.cast<String>() ?? ['Bilinmeyen yazar'],
      thumbnailUrl: (info['imageLinks'] != null && info['imageLinks']['thumbnail'] != null)
          ? (info['imageLinks']['thumbnail'] as String).replaceFirst('http:', 'https:')
          : '',
      description: info['description'] as String? ?? 'Açıklama bulunamadı.',
      publishedDate: info['publishedDate'] as String?,  // nullable olarak alıyoruz
      averageRating: (info['averageRating'] as num?)?.toDouble(),
      ratingsCount: info['ratingsCount'] as int?,
    );
  }
}
