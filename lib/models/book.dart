// lib/models/book.dart

import 'dart:convert';

String fixEncoding(String text) {
  try {
    return utf8.decode(latin1.encode(text));
  } catch (_) {
    return text;
  }
}

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
  final String? source;

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
    this.source,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    print("🧾 Gelen kitap verisi: $json");
    //final info = (json['volumeInfo'] as Map<String, dynamic>?) ?? {};
    if (json.containsKey('volumeInfo')) {
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
      /*return Book(
        id: json['id'] as String,
        //title: info['title'] as String? ?? '—',
        title: json['title'] ?? 'Bilinmeyen Başlık',
        /*authors:
            (info['authors'] as List<dynamic>?)?.cast<String>() ??
            ['Bilinmeyen yazar'],*/
        authors: _parseAuthors(json['authors']),
        thumbnailUrl: json['thumbnail_url'] ?? '',
        description: json['description'] ?? '',
        categories: cats,
        publisher: json['publisher'] ?? '',
        publishedDate: json['published_date']?.toString() ?? '',
        pageCount: json['pageCount'] ?? 0,
        industryIdentifiers: identifiers,
        averageRating:
            (json['average_rating'] is num)
                ? json['average_rating'].toDouble()
                : null,
        ratingsCount: info['ratingsCount'] as int?,
      );*/
      return Book(
        id: json['book_id']?.toString() ?? '',
        title: fixEncoding(json['title'] ?? 'Başlık yok'),
        authors: Book._parseAuthors(json['authors']),
        thumbnailUrl: json['thumbnail_url'] ?? '',
        description: fixEncoding(json['description'] ?? ''),
        categories: [], // ya da json'dan geliyorsa oradan çek
        publisher: fixEncoding(json['publisher'] ?? ''),
        publishedDate: json['publishedDate']?.toString() ?? '',
        pageCount: json['pageCount'] is int ? json['pageCount'] : 0,
        industryIdentifiers: [], // ya da parse et
        averageRating:
            json['averageRating'] is num
                ? json['averageRating'].toDouble()
                : null,
        ratingsCount: json['ratingsCount'] is int ? json['ratingsCount'] : 0,
        source: json['source'],
      );
    } else {
      return Book(
        /*id: json['id'] as String,
        title: json['title'] ?? 'Bilinmeyen Başlık',
        authors: _parseAuthors(json['authors']),
        thumbnailUrl: json['thumbnail_url'] ?? '',
        description: json['description'] ?? '',
        publisher: json['publisher'] ?? '',
        publishedDate: json['published_date']?.toString() ?? '',
        pageCount: json['pageCount'] ?? 0,
        industryIdentifiers:
            (json['industryIdentifiers'] as List<dynamic>?)?.cast<String>(),
        averageRating:
            (json['average_rating'] is num)
                ? json['average_rating'].toDouble()
                : null,
        ratingsCount: json['ratingsCount'] as int?,
        categories: <String>[],*/
        id: json['book_id']?.toString() ?? '',
        title: fixEncoding(json['title'] ?? 'Başlık yok'),
        authors: Book._parseAuthors(json['authors']),
        thumbnailUrl: json['thumbnail_url'] ?? '',
        description: fixEncoding(json['description'] ?? ''),
        categories: [], // ya da json'dan geliyorsa oradan çek
        publisher: fixEncoding(json['publisher'] ?? ''),
        publishedDate: json['publishedDate']?.toString() ?? '',
        pageCount: json['pageCount'] is int ? json['pageCount'] : 0,
        industryIdentifiers: [], // ya da parse et
        averageRating:
            json['averageRating'] is num
                ? json['averageRating'].toDouble()
                : null,
        ratingsCount: json['ratingsCount'] is int ? json['ratingsCount'] : 0,
        source: json['source'],
      );
    }
  }
  static List<String> _parseAuthors(dynamic rawAuthors) {
    if (rawAuthors == null) return [];
    if (rawAuthors is String) {
      try {
        final decoded = jsonDecode(rawAuthors);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {
        return [rawAuthors];
      }
    } else if (rawAuthors is List) {
      return List<String>.from(rawAuthors);
    }
    return [];
  }
}

class RecommendedBook {
  final String title;
  final List<String> authors;
  final String thumbnailUrl;
  final double score;

  RecommendedBook({
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
    required this.score,
  });

  factory RecommendedBook.fromJson(Map<String, dynamic> json) {
    return RecommendedBook(
      title: json['title'],
      authors: List<String>.from(json['authors']),
      thumbnailUrl: json['thumbnail_url'],
      score: json['score'].toDouble(),
    );
  }
}
