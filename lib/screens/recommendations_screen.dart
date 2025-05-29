/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

const String kBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://projembackend-production-4549.up.railway.app',
);

class RecommendationsScreen extends StatefulWidget {
  final List<Book> favoriteBooks;
  final void Function(Book) onToggleFavorite;
  final void Function(Book) onAddToLibrary;
  final Map<String, int?> userRatings;
  final void Function(Book, int) onRate;

  const RecommendationsScreen({
    Key? key,
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
  List<Book> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    print("🟡 Fonksiyon başladı");
    try {
      print("📦 SharedPreferences alınıyor...");
      final prefs = await SharedPreferences.getInstance();
      print("📦 prefs OK");

      final token = prefs.getString('jwt_token');
      print("🔑 Token alındı: $token");

      if (token == null || token.isEmpty) {
        print("❌ Token null veya boş! Fonksiyon sonlandırıldı.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://terrific-reprieve-production.up.railway.app/recommend',
      );
      print("📡 URL hazırlandı: $url");

      print("📡 İstek atılıyor...");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("✅ Yanıt kodu: ${response.statusCode}");
      print("📩 Yanıt içeriği: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawList = data['recommendations'];

        setState(() {
          _recommendedBooks =
              rawList.map((rec) {
                return Book(
                  id: rec['book_id'].toString(),
                  title: rec['title'] ?? 'Başlık yok',
                  authors: Book._parseAuthors(rec['authors']),
                  thumbnailUrl: rec['thumbnail_url'] ?? '',
                  publisher: rec['publisher'] ?? '',
                  publishedDate: rec['publishedDate'] ?? '',
                  description: rec['description'] ?? '',
                  categories: [],
                );
              }).toList();

          _isLoading = false;
        });
      } else {
        print("❌ API başarısız yanıt: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ TRY-CATCH HATASI: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Senin İçin Önerilenler", style: GoogleFonts.poppins()),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recommendations.isEmpty
              ? const Center(child: Text("Henüz öneri bulunamadı."))
              : ListView.builder(
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  final book = _recommendations[index];
                  final isFavorite = widget.favoriteBooks.contains(book);
                  final userRating = widget.userRatings[book.id];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.authors.join(", ")),
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => widget.onToggleFavorite(book),
                    ),
                    onTap: () => widget.onAddToLibrary(book),
                  );
                },
              ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecommendationsScreen extends StatefulWidget {
  final Future<List<Book>> Function() fetchRecommendations;
  final void Function(Book) onToggleFavorite;
  final void Function(Book) onAddToLibrary;
  final Map<String, double> userRatings;
  final void Function(Book, double) onRate;

  const RecommendationsScreen({
    super.key,
    required this.fetchRecommendations,
    required this.onToggleFavorite,
    required this.onAddToLibrary,
    required this.userRatings,
    required this.onRate,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<Book>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = widget.fetchRecommendations();
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(book.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title),
                Text(
                  book.authors.isNotEmpty
                      ? book.authors.join(", ")
                      : "Yazar bilgisi yok",
                ),
                if (book.source != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      book.source == "svd"
                          ? "🧠 SVD ile önerildi"
                          : "🌟 ${book.source!.toUpperCase()} önerisi",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                Text(book.publisher ?? "Yayınevi bilinmiyor"),
                Text(
                  book.description.isNotEmpty
                      ? book.description
                      : "Açıklama bulunamadı.",
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Kapat"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        title: const Text('Senin İçin Önerilenler'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        elevation: 0,
      ),
      body: FutureBuilder<List<Book>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Hiç öneri bulunamadı.'));
          }

          final recommendedBooks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recommendedBooks.length,
            itemBuilder: (context, index) {
              final book = recommendedBooks[index];
              final isFavorite = widget.userRatings.containsKey(book.id);
              final rating = widget.userRatings[book.id] ?? 0.0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () => _showBookDetails(context, book),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  book.thumbnailUrl.isNotEmpty
                                      ? Image.network(
                                        book.thumbnailUrl,
                                        height: 90,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        // yükleme sırasında bir spinner göster
                                        loadingBuilder: (ctx, child, progress) {
                                          if (progress == null) return child;
                                          return const SizedBox(
                                            height: 90,
                                            width: 60,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        // hata halinde kırık görsel ikonu göster
                                        errorBuilder:
                                            (_, __, ___) => const SizedBox(
                                              height: 90,
                                              width: 60,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                      )
                                      : const Icon(
                                        Icons.book,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book.authors.isNotEmpty
                                        ? book.authors.join(', ')
                                        : 'Yazar bilgisi yok',
                                  ),
                                  const SizedBox(height: 8),
                                  RatingBar.builder(
                                    initialRating: rating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 20,
                                    itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    itemBuilder:
                                        (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                    onRatingUpdate:
                                        (newRating) =>
                                            widget.onRate(book, newRating),
                                  ),
                                ],
                              ),
                            ),
                            // İstersen buradaki favori butonunu ekleyebilirsin:
                            // IconButton(
                            //   icon: Icon(
                            //     isFavorite ? Icons.favorite : Icons.favorite_border,
                            //     color: Colors.deepPurple,
                            //   ),
                            //   onPressed: () => widget.onToggleFavorite(book),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            if (book.source != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  book.source == "svd"
                                      ? "🧠 SVD ile önerildi"
                                      : "🌟 ${book.source!.toUpperCase()} önerisi",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.publisher?.isNotEmpty == true
                              ? "Yayınevi: ${book.publisher}"
                              : "Yayınevi yok",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.description.isNotEmpty
                              ? book.description
                              : "Açıklama bulunamadı.",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
