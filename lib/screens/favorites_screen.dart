// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId;
  final List<Book> favoriteBooks;
  final void Function(Book) onAddToLibrary;
  final Map<String,int> userRatings;
  final void Function(Book,int) onRate;

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

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favoriteBooks);
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
          'Favoriler',
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
      body: _favorites.isEmpty
          ? Center(
        child: Text(
          'Henüz favori kitabın yok 😊',
          style: AppTextStyle.BODY.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padVsmall),
        child: _isGrid
            ? _buildGrid(padH, padVmedium)
            : _buildList(padVmedium),
      ),
    );
  }

  Widget _buildList(double verticalSpace) {
    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => SizedBox(height: verticalSpace),
      itemBuilder: (context, idx) {
        final book = _favorites[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: AppColors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: book.thumbnailUrl.isNotEmpty
                ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
                : Icon(Icons.menu_book, size: 40, color: AppColors.accent),
            title: Text(
              book.title,
              style: AppTextStyle.BODY.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: rating > 0
                ? Row(
              children: List.generate(
                rating,
                    (_) => Icon(Icons.star, size: 12, color: AppColors.logoPink),
              ),
            )
                : null,
            trailing: TextButton.icon(
              onPressed: () {
                widget.onAddToLibrary(book);
                setState(() => _favorites.remove(book));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Kütüphaneye Ekle',
                style: AppTextStyle.BODY.copyWith(color: AppColors.accent),
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(
                  userId: widget.userId,
                  book: book,
                  isFavorite: true,
                  isInLibrary: false,
                  userRating: rating,
                  onToggleFavorite: (b) {
                    setState(() => _favorites.remove(b));
                  },
                  onToggleLibrary: (b) {
                    widget.onAddToLibrary(b);
                    setState(() => _favorites.remove(b));
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

  Widget _buildGrid(double horizontalSpace, double verticalSpace) {
    return GridView.builder(
      itemCount: _favorites.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: horizontalSpace,
        mainAxisSpacing: verticalSpace,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, idx) {
        final book = _favorites[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(
                userId: widget.userId,
                book: book,
                isFavorite: true,
                isInLibrary: false,
                userRating: rating,
                onToggleFavorite: (b) => setState(() => _favorites.remove(b)),
                onToggleLibrary: (b) {
                  widget.onAddToLibrary(b);
                  setState(() => _favorites.remove(b));
                },
                onRate: widget.onRate,
              ),
            ),
          ),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    child: Icon(Icons.menu_book,
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
                            (_) =>
                            Icon(Icons.star, size: 12, color: AppColors.logoPink),
                      ),
                    ),
                  ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final book = _favorites[idx];
                      widget.onAddToLibrary(book);
                      setState(() => _favorites.remove(book));
                    },
                    icon: Icon(Icons.add, color: AppColors.accent),
                    label: Text(
                      'Kütüphaneye Ekle',
                      style: AppTextStyle.MINI_DESCRIPTION_TEXT.copyWith(
                        color: AppColors.accent,
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
