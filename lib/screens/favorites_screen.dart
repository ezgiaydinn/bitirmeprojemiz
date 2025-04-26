// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  /// Kullanıcı ID’si parametresi
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text('Favoriler', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.purple.shade800,
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: _favorites.isEmpty
          ? Center(
        child: Text(
          'Henüz favori kitabın yok 😊',
          style: GoogleFonts.openSans(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: _isGrid ? _buildGrid() : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, idx) {
        final book = _favorites[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: ListTile(
            leading: book.thumbnailUrl.isNotEmpty
                ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
                : const Icon(Icons.menu_book, color: Colors.purple),
            title: Text(book.title, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
            subtitle: rating > 0
                ? Row(
              children: List.generate(
                rating,
                    (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
              ),
            )
                : null,
            trailing: TextButton.icon(
              onPressed: () {
                widget.onAddToLibrary(book);
                setState(() => _favorites.remove(book));
              },
              icon: const Icon(Icons.add, color: Colors.green),
              label: Text('Kütüphaneye Ekle', style: GoogleFonts.openSans()),
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
                  onToggleFavorite: (b) => setState(() => _favorites.remove(b)),
                  onToggleLibrary: widget.onAddToLibrary,
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
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.65),
      itemBuilder: (_, idx) {
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
                onToggleLibrary: widget.onAddToLibrary,
                onRate: widget.onRate,
              ),
            ),
          ),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: book.thumbnailUrl.isNotEmpty
                      ? Image.network(book.thumbnailUrl, fit: BoxFit.cover)
                      : const Icon(Icons.menu_book, size: 50, color: Colors.purple),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.openSans()),
                ),
                if (rating > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: List.generate(
                        rating,
                            (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade300),
                  onPressed: () {
                    widget.onAddToLibrary(book);
                    setState(() => _favorites.remove(book));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Kütüphaneye Ekle', style: GoogleFonts.openSans(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
