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

  const LibraryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Book>> _futureLibrary;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  void _loadLibrary() {
    _futureLibrary = _fetchLibrary();
  }

  Future<List<Book>> _fetchLibrary() async {
    final url = Uri.parse('$baseUrl/api/library/${widget.userId}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Kütüphane çekilemedi: ${res.statusCode}');
    }
  }

  Future<void> _removeFromLibrary(Book book) async {
    final url = Uri.parse('$baseUrl/api/library/remove');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId, 'bookId': book.id}),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('“${book.title}” kütüphaneden çıkarıldı.')),
      );
      // Listeyi yenile
      setState(() => _loadLibrary());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme başarısız: ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kütüphanen',
          style: AppTextStyle.HEADING.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.accent,
      ),
      body: FutureBuilder<List<Book>>(
        future: _futureLibrary,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}'));
          }

          final books = snap.data!;
          if (books.isEmpty) {
            return Center(
              child: Text(
                'Kütüphanen boş 😊',
                style: AppTextStyle.BODY.copyWith(fontSize: 18),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: books.length,
            itemBuilder: (ctx, i) {
              final b = books[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  /// —— Favoriler ekranındaki gibi kitap görseli ——
                  leading:
                      b.thumbnailUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              b.thumbnailUrl,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Icon(
                            Icons.menu_book,
                            size: 50,
                            color: AppColors.accent,
                          ),

                  /// —— Başlık ——
                  title: Text(
                    b.title.isNotEmpty ? b.title : 'Başlıksız kitap',
                    style: AppTextStyle.BODY.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// —— Yazar ——
                  subtitle:
                      b.authors.isNotEmpty
                          ? Text(
                            b.authors.join(', '),
                            style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT
                                .copyWith(fontWeight: FontWeight.w500),
                          )
                          : null,

                  /// —— Silme tuşu ——
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFromLibrary(b),
                  ),

                  /// —— Detay sayfasına git ——
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BookDetailScreen(
                              userId: widget.userId,
                              book: b,
                              isFavorite: false,
                              isInLibrary: true,
                              userRating: 0,
                              onToggleFavorite: (_) {},
                              onToggleLibrary: (_) {},
                              onRate: (_, __) {},
                            ),
                      ),
                    ).then((_) => setState(() => _loadLibrary()));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
