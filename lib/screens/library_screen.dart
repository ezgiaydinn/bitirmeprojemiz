// lib/screens/library_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://projembackend-production-4549.up.railway.app';

class LibraryScreen extends StatefulWidget {
  final String userId;
  final Map<String, int> userRatings;
  final void Function(Book) onRemoveFromLibrary;
  final void Function(Book, int) onRate;

  const LibraryScreen({
    Key? key,
    required this.userId,
    required this.userRatings,
    required this.onRemoveFromLibrary,
    required this.onRate,
  }) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> _library = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse('$baseUrl/api/library/${widget.userId}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _library = data.map((e) {
            // e bir Map<String,dynamic> ve bizim endpoint şu alanları döndürüyor:
            // id, title, authors (dizi), thumbnailUrl, description?, publisher?, vs.
            return Book(
              id: e['id'] as String,
              title: e['title'] as String,
              authors: List<String>.from(e['authors'] ?? []),
              thumbnailUrl: e['thumbnailUrl'] as String? ?? '',
              description: e['description'] as String? ?? 'Açıklama yok.',
              publisher: e['publisher'] as String?,
              publishedDate: e['publishedDate'] as String?,
              pageCount: e['pageCount'] as int?,
              industryIdentifiers: null,
              averageRating: null,
              ratingsCount: null,
            );
          }).toList();
        });
      } else {
        debugPrint('Kütüphane yüklenemedi: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Kütüphane yüklerken hata: $e');
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> _removeFromLibrary(Book book) async {
    final url = Uri.parse('$baseUrl/api/library/remove');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'bookId': book.id,
        }),
      );
      if (res.statusCode == 200) {
        widget.onRemoveFromLibrary(book);
        await _loadLibrary();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\"${book.title}\" kütüphaneden çıkarıldı!')),
        );
      } else {
        debugPrint('Çıkarma başarısız: ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çıkarma başarısız oldu 😕')),
        );
      }
    } catch (e) {
      debugPrint('Sunucuya bağlanılamadı ❌: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sunucu hatası 😕')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.accent,
            elevation: 0,
            title: Text('Kütüphane',
                style: AppTextStyle.HEADING.copyWith(color: Colors.white)),
          ),
          body: _library.isEmpty && !_loading
              ? Center(
            child: Text(
              'Kütüphanenizde kitap yok 😊',
              style: AppTextStyle.BODY.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          )
              : Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListView.separated(
              itemCount: _library.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final b = _library[i];
                final rating = widget.userRatings[b.id] ?? 0;
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: b.thumbnailUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        b.thumbnailUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.menu_book,
                        size: 50, color: Colors.grey),
                    title: Text(b.title,
                        style: AppTextStyle.BODY.copyWith(
                            fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.authors.join(', '),
                            style: AppTextStyle
                                .MINI_DEFAULT_DESCRIPTION_TEXT),
                        if (rating > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              rating,
                                  (_) => Icon(Icons.star,
                                  size: 12, color: AppColors.logoPink),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Çıkar'),
                      onPressed: () => _removeFromLibrary(b),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(
                            userId: widget.userId,
                            book: b,
                            isFavorite: false,
                            isInLibrary: true,
                            userRating: rating,
                            onToggleFavorite: (_) {},
                            onToggleLibrary: (_) {},
                            onRate: widget.onRate,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        if (_loading)
          Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }
}
