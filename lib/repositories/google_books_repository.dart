import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bitirmeprojesi/models/book.dart';

class GoogleBooksRepository {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> fetchBooks(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=$query'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => _parseBook(item)).toList();
      } else {
        throw Exception('Kitaplar getirilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata oluştu: $e');
    }
  }

  Book _parseBook(dynamic item) {
    final volumeInfo = item['volumeInfo'] ?? {};
    String thumbnail = volumeInfo['imageLinks']?['thumbnail'] ?? '';
    if (thumbnail.isNotEmpty && thumbnail.startsWith('http:')) {
      thumbnail = thumbnail.replaceFirst('http:', 'https:');
    }
    return Book(
      id: item['id'] ?? '',
      title: volumeInfo['title'] ?? 'Başlıksız',
      authors:
          (volumeInfo['authors'] != null && volumeInfo['authors'] is List)
              ? List<String>.from(volumeInfo['authors'])
              : ['Bilinmeyen Yazar'],
      thumbnailUrl:
          volumeInfo['imageLinks'] != null
              ? volumeInfo['imageLinks']['thumbnail'] ?? ''
              : '',
      description: '',
    );
  }
}
