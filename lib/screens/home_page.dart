// lib/screens/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/repositories/google_books_repository.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/screens/favorites_screen.dart';
import 'package:bitirmeprojesi/screens/library_screen.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';
import 'package:bitirmeprojesi/screens/profile_screen.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';

const String baseUrl = 'https://projembackend-production-4549.up.railway.app';

class HomePageScreen extends StatefulWidget {
  final String name;
  final String userId;

  const HomePageScreen({Key? key, required this.name, required this.userId})
    : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Future<List<Book>>? _futureBooks;
  final GoogleBooksRepository _repo = GoogleBooksRepository();

  final List<Book> _favoriteBooks = [];
  final List<Book> _libraryBooks = [];
  final Map<String, int> _userRatings = {};
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // ① Kullanıcı verilerini çek
    _futureBooks = null; // Başlangıçta kitap arama yok
  }

  /// ① Kullanıcının favori ve rating listelerini backend’den çeker
  Future<void> _loadUserData() async {
    try {
      // --- Favoriler ---
      final favRes = await http.get(
        Uri.parse('$baseUrl/api/favorites/${widget.userId}'),
      );
      if (favRes.statusCode == 200) {
        final List data = jsonDecode(favRes.body);
        setState(() {
          _favoriteBooks.clear();
          _favoriteBooks.addAll(
            data.map((e) => Book.fromJson(e as Map<String, dynamic>)),
          );
        });
      }

      // --- Rating’ler ---
      final rateRes = await http.get(
        Uri.parse('$baseUrl/api/ratings/${widget.userId}'),
      );
      if (rateRes.statusCode == 200) {
        final List data = jsonDecode(rateRes.body);
        setState(() {
          _libraryBooks.clear();
          _userRatings.clear();
          for (var e in data) {
            final book = Book.fromJson(e as Map<String, dynamic>);
            _libraryBooks.add(book);
            _userRatings[book.id] = (e['rating'] as num).toInt();
          }
        });
      }
    } catch (e) {
      debugPrint('Kullanıcı verisi yüklenirken hata: $e');
    }
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      setState(() => _selectedIndex = 1);
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => FavoritesScreen(
                userId: widget.userId,
                favoriteBooks: _favoriteBooks,
                onAddToLibrary: (b) {
                  setState(() {
                    _favoriteBooks.removeWhere((x) => x.id == b.id);
                    _libraryBooks.add(b);
                  });
                },
                userRatings: _userRatings,
                onRate: (b, r) => setState(() => _userRatings[b.id] = r),
              ),
        ),
      ).then((_) => setState(() => _selectedIndex = 1));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LibraryScreen(userId: widget.userId)),
      ).then((_) => setState(() => _selectedIndex = 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final headerHeight = h * 0.25;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: DefaultTabController(
          length: 1,
          child: NestedScrollView(
            headerSliverBuilder:
                (_, __) => [
                  SliverAppBar(
                    backgroundColor: AppColors.accent,
                    expandedHeight: headerHeight,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      title: Text(
                        'Merhaba, ${widget.name}!',
                        style: AppTextStyle.BODY.copyWith(color: Colors.white),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.8),
                              AppColors.accent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileScreen(
                                      name: widget.name,
                                      userId: widget.userId,
                                    ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
            body: Column(
              children: [
                // Arama kutusu
                Padding(
                  padding: EdgeInsets.all(w * 0.05),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Kitap ara...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.greyMedium,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (q) {
                      setState(() {
                        _futureBooks = _repo.fetchBooks(q);
                      });
                    },
                  ),
                ),

                // İçerik
                Expanded(
                  child:
                      _futureBooks == null
                          ? Center(
                            child: Text(
                              'Bir kitap arayın...',
                              style: AppTextStyle.BODY,
                            ),
                          )
                          : FutureBuilder<List<Book>>(
                            future: _futureBooks,
                            builder: (ctx, snap) {
                              if (snap.connectionState !=
                                  ConnectionState.done) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snap.hasError) {
                                return Center(
                                  child: Text(
                                    'Hata: ${snap.error}',
                                    style: AppTextStyle.BODY,
                                  ),
                                );
                              }
                              final books = snap.data ?? [];
                              return GridView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.05,
                                  vertical: h * 0.02,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: w * 0.05,
                                      mainAxisSpacing: h * 0.02,
                                      childAspectRatio: 0.6,
                                    ),
                                itemCount: books.length,
                                itemBuilder: (_, i) => _buildBookCard(books[i]),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.logoPink,
        unselectedItemColor: AppColors.greyText,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Kütüphane',
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    final isFav = _favoriteBooks.any((b) => b.id == book.id);
    final inLib = _libraryBooks.any((b) => b.id == book.id);
    final rating = _userRatings[book.id] ?? 0;

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BookDetailScreen(
                    userId: widget.userId,
                    book: book,
                    isFavorite: isFav,
                    isInLibrary: inLib,
                    userRating: rating,
                    onToggleFavorite: (b) {
                      setState(() {
                        if (isFav)
                          _favoriteBooks.removeWhere((x) => x.id == b.id);
                        else
                          _favoriteBooks.add(b);
                      });
                    },
                    onToggleLibrary: (b) {
                      setState(() {
                        if (inLib) {
                          _libraryBooks.removeWhere((x) => x.id == b.id);
                          _userRatings.remove(b.id);
                        } else {
                          _libraryBooks.add(b);
                        }
                      });
                    },
                    onRate: (b, r) => setState(() => _userRatings[b.id] = r),
                  ),
            ),
          ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    book.thumbnailUrl.isNotEmpty
                        ? Image.network(book.thumbnailUrl, fit: BoxFit.cover)
                        : const Icon(Icons.book, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                book.title,
                style: AppTextStyle.BODY,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                book.authors.isNotEmpty
                    ? book.authors.join(', ')
                    : 'Bilinmeyen Yazar',
                style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.logoDarkBlue, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Bookify',
              style: AppTextStyle.HEADING.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.accent),
            title: Text('Ayarlar', style: AppTextStyle.BODY),
          ),
          ListTile(
            leading: Icon(Icons.info, color: AppColors.accent),
            title: Text('Hakkında', style: AppTextStyle.BODY),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.logoPink),
            title: Text(
              'Çıkış Yap',
              style: AppTextStyle.BODY.copyWith(color: AppColors.logoPink),
            ),
            onTap:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
          ),
        ],
      ),
    );
  }
}
