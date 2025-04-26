// lib/screens/recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart' show BookDetailScreen;
import 'package:google_fonts/google_fonts.dart';

class RecommendationsScreen extends StatefulWidget {
  /// Kullanıcı ID’si parametresi
  final String userId;

  final List<Book> recommendations;
  final List<Book> favoriteBooks;
  final void Function(Book) onToggleFavorite;
  final void Function(Book) onAddToLibrary;
  final Map<String, int?> userRatings;
  final void Function(Book, int) onRate;

  const RecommendationsScreen({
    Key? key,
    required this.userId,
    required this.recommendations,
    required this.favoriteBooks,
    required this.onToggleFavorite,
    required this.onAddToLibrary,
    required this.userRatings,
    required this.onRate,
  }) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late List<Book> _recs;

  @override
  void initState() {
    super.initState();
    _recs = List.from(widget.recommendations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tüm Öneriler', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.purple.shade800),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB39DDB), Color(0xFFE1BEE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: _recs.isEmpty
          ? Center(
        child: Text(
          'Öneri kalmadı 😊',
          style: GoogleFonts.openSans(fontSize: 18, color: Colors.purple.shade400),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _recs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, idx) {
          final book = _recs[idx];
          final fav = widget.favoriteBooks.any((b) => b.id == book.id);
          final rating = widget.userRatings[book.id];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: ListTile(
              leading: book.thumbnailUrl.isNotEmpty
                  ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
                  : const Icon(Icons.menu_book, color: Colors.purple),
              title: Text(book.title, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.authors.join(', '),
                    style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey[700]),
                  ),
                  if (rating != null && rating > 0)
                    Row(
                      children: List.generate(
                        rating,
                            (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? Colors.redAccent : Colors.grey,
                    ),
                    onPressed: () {
                      widget.onToggleFavorite(book);
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      widget.onAddToLibrary(book);
                      setState(() => _recs.remove(book));
                    },
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(
                    userId: widget.userId,
                    book: book,
                    isFavorite: fav,
                    isInLibrary: false,
                    userRating: rating ?? 0,
                    onToggleFavorite: widget.onToggleFavorite,
                    onToggleLibrary: widget.onAddToLibrary,
                    onRate: widget.onRate,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
