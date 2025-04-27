// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:google_fonts/google_fonts.dart';

class BookDetailScreen extends StatefulWidget {
  /// Kullanıcı ID’si parametresi
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

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
    _inLib = widget.isInLibrary;
    _currRating = widget.userRating;
  }

  Widget _buildStar(int idx) {
    final filled = idx <= _currRating;
    return IconButton(
      icon: Icon(
        filled ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
      onPressed: _inLib
          ? () {
        // İleride widget.userId kullanarak API çağrısı yapabilirsin
        widget.onRate(widget.book, idx);
        setState(() => _currRating = idx);
      }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: Text(b.title, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (b.thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(b.thumbnailUrl, height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: const Icon(Icons.menu_book, size: 80, color: Colors.purple),
            ),

          const SizedBox(height: 16),
          Text(b.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Yazar: ${b.authors.join(', ')}',
              textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 8),
          if (b.publishedDate != null)
            Text('Yayın Yılı: ${b.publishedDate}',
                textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 12),
          if (b.averageRating != null)
            Text('Ortalama Puan: ${b.averageRating} (${b.ratingsCount ?? 0} oy)',
                textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[800])),

          if (_inLib) ...[
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => _buildStar(i + 1))),
          ],

          const SizedBox(height: 24),
          Text(b.description, textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 16)),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border),
                label: Text(_isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade100,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  widget.onToggleFavorite(b);
                  setState(() => _isFav = !_isFav);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(_inLib ? Icons.remove : Icons.add),
                label: Text(_inLib ? 'Kütüphaneden Çıkar' : 'Kütüphaneye Ekle'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.purpleAccent.shade100),
                  foregroundColor: Colors.purpleAccent.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  widget.onToggleLibrary(b);
                  setState(() {
                    _inLib = !_inLib;
                    if (!_inLib) _currRating = 0;
                  });
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
