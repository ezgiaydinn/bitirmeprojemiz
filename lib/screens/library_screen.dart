// lib/screens/library_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryScreen extends StatefulWidget {
  /// Kullanıcı ID’si parametresi
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text('Kütüphanen', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
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
      body: _library.isEmpty
          ? Center(
        child: Text(
          'Henüz kütüphanene kitap eklemedin 😊',
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
      itemCount: _library.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, idx) {
        final book = _library[idx];
        final rating = widget.userRatings[book.id] ?? 0;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: ListTile(
            leading: book.thumbnailUrl.isNotEmpty
                ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
                : const Icon(Icons.book, color: Colors.purple),
            title: Text(book.title, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
            subtitle: rating > 0
                ? Row(
              children: List.generate(
                rating,
                    (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
              ),
            )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.grey,
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
                  onToggleFavorite: (_) {}, // Dilersen buraya da callback ekleyebilirsin
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

  Widget _buildGrid() {
    return GridView.builder(
      itemCount: _library.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, idx) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: book.thumbnailUrl.isNotEmpty
                      ? Image.network(book.thumbnailUrl, fit: BoxFit.cover)
                      : const Icon(Icons.book, size: 50, color: Colors.purple),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(),
                  ),
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
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade400)),
                  onPressed: () {
                    widget.onRemoveFromLibrary(book);
                    setState(() {
                      _library.remove(book);
                      widget.userRatings.remove(book.id);
                    });
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  label: Text('Sil', style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
