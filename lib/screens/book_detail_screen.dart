// lib/screens/book_detail_screen.dart
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'package:http/http.dart' as http;

class BookDetailScreen extends StatefulWidget {
  final String userId;
  final Book book;
  final bool isFavorite;
  final bool isInLibrary;
  final int userRating;
  final void Function(Book) onToggleFavorite;
  final void Function(Book) onToggleLibrary;
  final void Function(Book, int) onRate;

  const BookDetailScreen({
    Key? key,
    required this.userId,
    required this.book,
    required this.isFavorite,
    required this.isInLibrary,
    this.userRating = 0,
    required this.onToggleFavorite,
    required this.onToggleLibrary,
    required this.onRate,
  }) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late bool _isFav;
  late bool _inLib;
  late int _currRating;
  bool _descExpanded = false;
  Color _bgColor = AppColors.logoDarkBlue;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
    _inLib = widget.isInLibrary;
    _currRating = widget.userRating;
    _generateDominantColor();
  }

  Future<void> _generateDominantColor() async {
    if (widget.book.thumbnailUrl.isEmpty) return;
    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.book.thumbnailUrl),
    );
    if (palette.dominantColor != null) {
      setState(() => _bgColor = palette.dominantColor!.color);
    }
  }

  Future<void> saveFavoriteBook() async {
    final url = Uri.parse(
      'https://projembackend-production-4549.up.railway.app/api/favorites/save',
    );
    final body = {
      'userId': widget.userId,
      'bookId': widget.book.id,
      'title': widget.book.title,
      'authors': widget.book.authors,
      'thumbnailUrl': widget.book.thumbnailUrl,
      'publishedDate': widget.book.publishedDate,
      'pageCount': widget.book.pageCount,
      'publisher': widget.book.publisher,
      'description': widget.book.description,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        debugPrint('Favori kitap kaydedildi ✅');
      } else {
        debugPrint('Favori kitap kaydedilemedi ❌: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sunucuya bağlanılamadı ❌: $e');
    }
  }

  Future<void> deleteFavoriteBook() async {
    final url = Uri.parse(
      'https://projembackend-production-4549.up.railway.app/api/favorites/remove',
    );
    final body = {'userId': widget.userId, 'bookId': widget.book.id};
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        debugPrint('Favori kitap silindi ✅');
      } else {
        debugPrint('Favori kitap silinemedi ❌: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sunucuya bağlanılamadı ❌: $e');
    }
  }

  Future<void> saveRating(int rating) async {
    final url = Uri.parse(
      'https://projembackend-production-4549.up.railway.app/api/ratings/save',
    );
    final body = {
      'userId': widget.userId,
      'bookId': widget.book.id,
      'rating': rating,
      'title': widget.book.title,
      'authors': widget.book.authors,
      'thumbnailUrl': widget.book.thumbnailUrl,
      'publishedDate': widget.book.publishedDate,
      'pageCount': widget.book.pageCount,
      'publisher': widget.book.publisher,
      'description': widget.book.description,
    };
    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('Rating kaydedilemedi: $e');
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Puanını Seç', style: AppTextStyle.HEADING),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final idx = i + 1;
            return IconButton(
              splashRadius: 24,
              icon: Icon(
                idx <= _currRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                widget.onRate(widget.book, idx);
                setState(() => _currRating = idx);
                saveRating(idx);
                Navigator.pop(context);
              },
            );
          }),
        ),
      ),
    );
  }

  void _shareBook() async {
    final b = widget.book;
    final msg = '''
📚 ${b.title} – ${b.authors.join(', ')}

https://books.google.com/books?id=${b.id}
''';
    final box = context.findRenderObject() as RenderBox?;
    try {
      await Share.share(
        msg,
        sharePositionOrigin:
        box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero,
      );
    } catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım açılamadı 😕')),
        );
      }
    }
  }

  // --- UI yardımcı buton ---
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) =>
      InkWell(
        onTap: enabled ? onTap : null,
        child: Column(
          children: [
            Icon(
              icon,
              color: enabled ? AppColors.white : AppColors.white.withAlpha(120),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT.copyWith(
                color:
                enabled ? AppColors.white : AppColors.white.withAlpha(120),
              ),
            ),
          ],
        ),
      );

  Widget _userRatingView() {
    if (!_inLib || _currRating == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
                  (i) => Icon(
                i < _currRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Senin puanın: $_currRating / 5',
            style: AppTextStyle.MINI_DESCRIPTION_BOLD.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String? value, Color color) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTextStyle.MINI_DESCRIPTION_BOLD.copyWith(color: color),
          ),
          Expanded(
            child: Text(value, style: AppTextStyle.BODY.copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    final size = MediaQuery.of(context).size;
    final coverW = size.width * 0.38;
    final coverH = coverW * 1.5;
    final mutedWhite = AppColors.white70;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // ← İşte buraya AppBar ekledik
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Geri dönme butonu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Paylaşma butonu
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.white),
            onPressed: _shareBook,
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: _bgColor.withOpacity(0.65)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: b.thumbnailUrl.isNotEmpty
                              ? Image.network(
                            b.thumbnailUrl,
                            width: coverW,
                            height: coverH,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: coverW,
                            height: coverH,
                            color: AppColors.greyMedium,
                            child: const Icon(
                              Icons.menu_book,
                              size: 48,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.025),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                          ),
                          child: Text(
                            b.title,
                            textAlign: TextAlign.center,
                            style:
                            AppTextStyle.HEADING.copyWith(color: AppColors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.authors.join(', '),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT
                              .copyWith(color: mutedWhite),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _actionButton(
                                icon: _isFav ? Icons.favorite : Icons.favorite_border,
                                label: _isFav ? 'Favoriden' : 'Favori',
                                onTap: () async {
                                  setState(() => _isFav = !_isFav);
                                  if (_isFav) {
                                    await saveFavoriteBook();
                                  } else {
                                    await deleteFavoriteBook();
                                  }
                                  widget.onToggleFavorite(b);
                                },
                              ),
                              _actionButton(
                                icon: _inLib ? Icons.library_books : Icons.library_add,
                                label: _inLib ? 'Kütüphaneden' : 'Kütüphaneye',
                                onTap: () async {
                                  if (_inLib) {
                                    // mevcut kütüphaneden çıkarma
                                    final url = Uri.parse(
                                      'https://projembackend-production-4549.up.railway.app/api/library/remove',
                                    );
                                    final res = await http.post(
                                      url,
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({
                                        'userId': widget.userId,
                                        'bookId': widget.book.id,
                                      }),
                                    );
                                    if (res.statusCode == 200) {
                                      widget.onToggleLibrary(b);
                                      setState(() => _inLib = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('\"${b.title}\" kütüphaneden çıkarıldı!'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Çıkarma başarısız oldu 😕'),
                                        ),
                                      );
                                    }
                                  } else {
                                    // **Burayı değiştirdik:** kütüphaneye ekleme
                                    final url = Uri.parse(
                                      'https://projembackend-production-4549.up.railway.app/api/favorite-to-library',
                                    );
                                    final res = await http.post(
                                      url,
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({
                                        'userId': widget.userId,
                                        'bookId': widget.book.id,
                                      }),
                                    );
                                    if (res.statusCode == 200) {
                                      widget.onToggleLibrary(b);
                                      setState(() => _inLib = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('\"${b.title}\" kütüphaneye eklendi!'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ekleme başarısız oldu 😕'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              _actionButton(
                                icon: Icons.star,
                                label: 'Puanla',
                                enabled: _inLib,
                                onTap: _showRatingDialog,
                              ),
                            ],
                          ),
                        ),
                        _userRatingView(),
                        SizedBox(height: size.height * 0.035),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.08,
                          ),
                          child: Column(
                            children: [
                              Text(
                                b.description,
                                textAlign: TextAlign.center,
                                maxLines: _descExpanded ? null : 3,
                                overflow: _descExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: AppTextStyle.BODY.copyWith(color: mutedWhite),
                              ),
                              InkWell(
                                onTap: () => setState(() => _descExpanded = !_descExpanded),
                                child: Text(
                                  _descExpanded ? 'daha az göster' : 'daha çok oku',
                                  style: AppTextStyle.MINI_DESCRIPTION_BOLD
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.08,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _metaRow('Yayıncı', b.publisher, mutedWhite),
                              _metaRow('Yıl', b.publishedDate, mutedWhite),
                              _metaRow('Sayfa', b.pageCount?.toString(), mutedWhite),
                              _metaRow(
                                'ISBN',
                                (b.industryIdentifiers != null &&
                                    b.industryIdentifiers!.isNotEmpty)
                                    ? b.industryIdentifiers!.join(', ')
                                    : null,
                                mutedWhite,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
