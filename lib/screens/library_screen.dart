// lib/screens/library_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';

class LibraryScreen extends StatefulWidget {
  final String userId;
  final List<Book> libraryBooks;
  final Map<String,int> userRatings;
  final void Function(Book) onRemoveFromLibrary;
  final void Function(Book,int) onRate;

  const LibraryScreen({
    Key? key,
    required this.userId,
    required this.libraryBooks,
    required this.userRatings,
    required this.onRemoveFromLibrary,
    required this.onRate,
  }) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late List<Book> _library;
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _library = List.from(widget.libraryBooks);
  }

  @override
  Widget build(BuildContext context) {
    // Dinamik boyutlandırma
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final padH = w * 0.05;
    final padVsmall = h * 0.02;
    final padVmedium = h * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        elevation: 0,
        title: Text(
          'Kütüphanen',
          style: AppTextStyle.HEADING.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGrid ? Icons.view_list : Icons.grid_view,
              color: AppColors.white,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: _library.isEmpty
          ? Center(
        child: Text(
          'Henüz kütüphanene kitap eklemedin 😊',
          style: AppTextStyle.BODY.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padVsmall),
        child: _isGrid ? _buildGrid(padH, padVmedium) : _buildList(padVmedium),
      ),
    );
  }

  Widget _buildList(double padV) {
    return ListView.separated(
      itemCount: _library.length,
      separatorBuilder: (_, __) => SizedBox(height: padV),
      itemBuilder: (context, idx) {
        final book = _library[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: AppColors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: book.thumbnailUrl.isNotEmpty
                ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
                : Icon(Icons.book, color: AppColors.accent, size: 40),
            title: Text(
              book.title,
              style: AppTextStyle.BODY.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: rating > 0
                ? Row(
              children: List.generate(
                rating,
                    (_) => Icon(Icons.star,
                    size: 12, color: AppColors.logoPink),
              ),
            )
                : null,
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.greyText),
              onPressed: () {
                widget.onRemoveFromLibrary(book);
                setState(() {
                  _library.remove(book);
                  widget.userRatings.remove(book.id);
                });
              },
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(
                  userId: widget.userId,
                  book: book,
                  isFavorite: false,
                  isInLibrary: true,
                  userRating: rating,
                  onToggleFavorite: (_) {},
                  onToggleLibrary: (b) {
                    widget.onRemoveFromLibrary(b);
                    setState(() => _library.remove(b));
                    widget.userRatings.remove(b.id);
                  },
                  onRate: widget.onRate,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(double padH, double padV) {
    return GridView.builder(
      itemCount: _library.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: padH,
        mainAxisSpacing: padV,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, idx) {
        final book = _library[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(
                userId: widget.userId,
                book: book,
                isFavorite: false,
                isInLibrary: true,
                userRating: rating,
                onToggleFavorite: (_) {},
                onToggleLibrary: (b) {
                  widget.onRemoveFromLibrary(b);
                  setState(() => _library.remove(b));
                  widget.userRatings.remove(b.id);
                },
                onRate: widget.onRate,
              ),
            ),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: book.thumbnailUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(book.thumbnailUrl, fit: BoxFit.cover),
                  )
                      : Center(
                    child: Icon(Icons.book,
                        size: 50, color: AppColors.accent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.BODY,
                  ),
                ),
                if (rating > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: List.generate(
                        rating,
                            (_) => Icon(Icons.star,
                            size: 12, color: AppColors.logoPink),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.greyMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    onPressed: () {
                      final book = _library[idx];
                      widget.onRemoveFromLibrary(book);
                      setState(() {
                        _library.remove(book);
                        widget.userRatings.remove(book.id);
                      });
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.greyText),
                    label: Text(
                      'Sil',
                      style: AppTextStyle.MINI_DESCRIPTION_TEXT.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
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
