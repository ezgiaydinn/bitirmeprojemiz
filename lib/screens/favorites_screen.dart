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
  final void Function(Book) onAddToLibrary;
  final Map<String, int> userRatings;
  final void Function(Book, int) onRate;

  const FavoritesScreen({
    Key? key,
    required this.userId,
    required this.onAddToLibrary,
    required this.userRatings,
    required this.onRate,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Book> _favorites = [];
  bool _isGrid = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/favorites/${widget.userId}'),
      headers: {'Cache-Control': 'no-cache'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        _favorites = data.map((j) => Book.fromJson(j)).toList();
      });
    }
  }

  Future<List<Book>> _fetchFavoritesFromApi() async {
    final url = Uri.parse('$baseUrl/api/favorites/${widget.userId}');
    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cache-control': 'no-cache',
      },
    );
    debugPrint('🚀 [GET /favorites] status: ${res.statusCode}');
    debugPrint('🚀 [GET /favorites] body:   ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('Favoriler yüklenemedi (${res.statusCode})');
    }

    final List<dynamic> list = jsonDecode(res.body);
    return list.map<Book>((item) {
      // 1) Eğer backend gerçek bir JSON listesi döndürdüyse:
      List<String> authorsList = [];
      final rawAuthors = item['authors'];
      if (rawAuthors is List) {
        authorsList =
            rawAuthors
                .map((e) => (e ?? '').toString())
                .where((s) => s.isNotEmpty)
                .toList();
      }
      // 2) Hâlâ boşsa, eski string split mantığı:
      else if (rawAuthors is String) {
        authorsList =
            rawAuthors
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
      }
      // 3) Son çare: fallback
      if (authorsList.isEmpty) {
        authorsList = ['Bilinmeyen yazar'];
      }

      List<String> genres = [];
      final rawGenres = item['genreJson'];
      if (rawGenres != null) {
        if (rawGenres is String) {
          if (rawGenres.startsWith('[') && rawGenres.endsWith(']')) {
            try {
              final parsed = jsonDecode(rawGenres);
              if (parsed is List) {
                genres = parsed.map((e) => e.toString()).toList();
              }
            } catch (_) {}
          }
          if (genres.isEmpty) {
            genres = [rawGenres];
          }
        } else if (rawGenres is List) {
          genres = rawGenres.map((e) => e.toString()).toList();
        }
      }
      if (genres.isEmpty) genres = ['—'];

      return Book(
        id: item['id'] as String,
        title: item['title'] as String,
        authors: authorsList,
        thumbnailUrl: (item['thumbnailUrl'] as String?) ?? '',
        description: 'Açıklama bulunamadı.',
        categories: item['genre'] as List<String>,
        publisher: null,
        publishedDate: null,
        pageCount: null,
        industryIdentifiers: null,
        averageRating: null,
        ratingsCount: null,
      );
    }).toList();
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
    if (ok) {
      await _loadFavorites();
      widget.onAddToLibrary(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\"${book.title}\" kütüphaneye taşındı!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Taşıma başarısız oldu 😕')));
    }
    setState(() => _loading = false);
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
            backgroundColor: Colors.deepPurple.shade200,
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
          color: const Color(0xFFF4ECFF), // pastel-lila zemin
          elevation: 5, // hafif gölge
          shape: RoundedRectangleBorder(
            // yuvarlak köşe
            borderRadius: BorderRadius.circular(16),
          ),

          child: ListTile(
            tileColor: const Color(0xFFF4ECFF), // kartla aynı zemin
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
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
            title: Text(
              b.title,
              style: AppTextStyle.BODY.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.authors.join(', '),
                  style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      rating,
                      (_) =>
                          Icon(Icons.star, size: 12, color: AppColors.logoPink),
                    ),
                  ),
                ],
              ],
            ),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.library_add, size: 18),
              label: const Text('Taşı'),
              onPressed: () => _onAddToLibrary(b),
            ),
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
                          onToggleFavorite: (_) => _loadFavorites(),
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
          color: const Color(0xFFF4ECFF),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                          onToggleFavorite: (_) => _loadFavorites(),
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
                    b.title,
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
                    b.authors.join(', '),
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
                      backgroundColor: Colors.deepPurple.shade200,
                      minimumSize: const Size.fromHeight(36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.library_add, size: 18),
                    label: const Text(
                      'Kütüphaneye Taşı',
                      style: TextStyle(color: Colors.white),
                    ),
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
