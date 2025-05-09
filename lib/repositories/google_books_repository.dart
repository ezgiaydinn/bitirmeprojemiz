// lib/data/google_books_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bitirmeprojesi/models/book.dart';

class GoogleBooksRepository {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> fetchBooks(String query) async {
    try {
      final url =
          '$_baseUrl?q=${Uri.encodeQueryComponent(query)}&maxResults=20';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map<Book>(_parseBook).toList();
      } else {
        throw Exception('Kitaplar getirilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  // --- ÖNEMLİ KISIM: tüm alanları parse ediyoruz ---
  Book _parseBook(dynamic item) {
    final info = (item['volumeInfo'] ?? {}) as Map<String, dynamic>;

    // ISBN’leri listeye çevir
    final ids =
        (info['industryIdentifiers'] as List<dynamic>?)
            ?.map((e) => (e as Map<String, dynamic>)['identifier'] as String?)
            .whereType<String>()
            .toList();

    // Küçük http→https düzeltmesi
    String thumb = info['imageLinks']?['thumbnail'] ?? '';
    if (thumb.startsWith('http:'))
      thumb = thumb.replaceFirst('http:', 'https:');

    return Book(
      id: item['id'] ?? '',
      title: info['title'] ?? 'Başlıksız',
      authors:
          (info['authors'] as List<dynamic>?)?.cast<String>() ??
          ['Bilinmeyen Yazar'],
      thumbnailUrl: thumb,
      description: info['description'] ?? 'Açıklama bulunamadı.',
      categories: (info['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      publisher: info['publisher'],
      publishedDate: info['publishedDate'],
      pageCount: info['pageCount'],
      industryIdentifiers: ids,
      averageRating: (info['averageRating'] as num?)?.toDouble(),
      ratingsCount: info['ratingsCount'],
    );
  }
}
