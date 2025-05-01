// lib/screens/favorites_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://projembackend-production-4549.up.railway.app';

class FavoritesScreen extends StatefulWidget {
  final String userId;
  final List<Book> favoriteBooks;
  final void Function(Book) onAddToLibrary;
  final Map<String, int> userRatings;
  final void Function(Book, int) onRate;

  const FavoritesScreen({
    Key? key,
    required this.userId,
    required this.favoriteBooks,
    required this.onAddToLibrary,
    required this.userRatings,
    required this.onRate,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Book> _favorites;
  bool _isGrid = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favoriteBooks);
  }

  Future<bool> _moveFavoriteToLibrary(String bookId) async {
    final url = Uri.parse('$baseUrl/api/favorite-to-library');
    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': widget.userId, 'bookId': bookId}),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('🚀 [Fav→Lib] status: ${res.statusCode}');
      debugPrint('🚀 [Fav→Lib] body:   ${res.body}');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [Fav→Lib] exception: $e');
      return false;
    }
  }

  void _onAddToLibrary(Book book) async {
    setState(() => _loading = true);
    final ok = await _moveFavoriteToLibrary(book.id);
    setState(() => _loading = false);
    if (ok) {
      widget.onAddToLibrary(book);
      setState(() => _favorites.remove(book));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\"${book.title}\" kütüphaneye taşındı!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Taşıma başarısız oldu 😕')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final padH = w * 0.05;
    final padV = w * 0.03;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.accent,
            elevation: 0,
            title: Text(
              'Favoriler',
              style: AppTextStyle.HEADING.copyWith(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGrid ? Icons.view_list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _isGrid = !_isGrid),
              ),
            ],
          ),
          body:
              _favorites.isEmpty
                  ? Center(
                    child: Text(
                      'Henüz favori kitabın yok 😊',
                      style: AppTextStyle.BODY.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padH,
                      vertical: padV,
                    ),
                    child: _isGrid ? _buildGrid() : _buildList(),
                  ),
        ),
        if (_loading)
          Container(
            color: Colors.black38,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final b = _favorites[i];
        final rating = widget.userRatings[b.id] ?? 0;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            // ✔ Thumbnail zaten var
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
                    : const Icon(Icons.menu_book, size: 50, color: Colors.grey),

            // ✔ Burada artık title ve authors gösteriyoruz
            title: Text(
              b.title.isNotEmpty ? b.title : 'Başlıksız Kitap',
              style: AppTextStyle.BODY.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Yazar adı
                Text(
                  b.authors.isNotEmpty
                      ? b.authors.join(',')
                      : 'Bilinmeyen yazar',
                  style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                ),
                const SizedBox(height: 4),
                // 2) Rating yıldızları
                if (rating > 0)
                  Row(
                    children: List.generate(
                      rating,
                      (_) =>
                          Icon(Icons.star, size: 12, color: AppColors.logoPink),
                    ),
                  ),
              ],
            ),

            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.library_add, size: 18),
              label: const Text('Taşı'),
              onPressed: () => _onAddToLibrary(b),
            ),

            // ✔ Tıklayınca detay sayfasına gidiyor
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookDetailScreen(
                          userId: widget.userId,
                          book: b,
                          isFavorite: true,
                          isInLibrary: false,
                          userRating: rating,
                          onToggleFavorite:
                              (_) => setState(() => _favorites.remove(b)),
                          onToggleLibrary: (_) => _onAddToLibrary(b),
                          onRate: widget.onRate,
                        ),
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      itemCount: _favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (ctx, i) {
        final b = _favorites[i];
        final rating = widget.userRatings[b.id] ?? 0;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookDetailScreen(
                          userId: widget.userId,
                          book: b,
                          isFavorite: true,
                          isInLibrary: false,
                          userRating: rating,
                          onToggleFavorite:
                              (_) => setState(() => _favorites.remove(b)),
                          onToggleLibrary: (_) => _onAddToLibrary(b),
                          onRate: widget.onRate,
                        ),
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child:
                      b.thumbnailUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              b.thumbnailUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) {
                                if (prog == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          )
                          : const Icon(
                            Icons.menu_book,
                            size: 60,
                            color: Colors.grey,
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    b.title.isNotEmpty ? b.title : 'Başlıksız Kitap',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.BODY.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    b.authors.isNotEmpty
                        ? b.authors.join(',')
                        : 'Bilinmeyen yazar',
                    style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                  ),
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: List.generate(
                        rating,
                        (_) => Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.logoPink,
                        ),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size.fromHeight(36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.library_add, size: 18),
                    label: const Text('Kütüphaneye Taşı'),
                    onPressed: () => _onAddToLibrary(b),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
