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
import 'package:bitirmeprojesi/screens/recommendations_screen.dart';
import 'package:bitirmeprojesi/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kBaseUrl = 'https://projembackend-production-4549.up.railway.app';

class HomePageScreen extends StatefulWidget {
  final String name;
  final String userId;
  final String email;

  const HomePageScreen({
    super.key,
    required this.name,
    required this.userId,
    required this.email,
  });

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Book>>? _futureBooks;
  final GoogleBooksRepository _repo = GoogleBooksRepository();
  final List<Book> _favoriteBooks = [];
  final List<Book> _libraryBooks = [];
  final Map<String, double> _userRatings = {};
  int _selectedIndex = 1;
  String _displayName = '';
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() =>
      _displayName = prefs.getString('user_name') ?? 'Misafir');
    });
    _loadUserData();
    _futureBooks = null;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Book>> fetchRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return [];
    final response = await http.get(
      Uri.parse(
          'https://terrific-reprieve-production.up.railway.app/recommend'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['recommendations'] as List)
          .map((e) => Book.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<void> _loadUserData() async {
    try {
      final favRes = await http.get(
        Uri.parse('$kBaseUrl/api/favorites/${widget.userId}'),
      );
      if (favRes.statusCode == 200) {
        final List data = jsonDecode(favRes.body);
        if (!mounted) return;
        setState(() {
          _favoriteBooks
            ..clear()
            ..addAll(data.map((e) => Book.fromJson(e)).toList());
        });
      }

      final rateRes = await http.get(
        Uri.parse('$kBaseUrl/api/ratings/${widget.userId}'),
      );
      if (rateRes.statusCode == 200) {
        final List data = jsonDecode(rateRes.body);
        if (!mounted) return;
        setState(() {
          _libraryBooks.clear();
          _userRatings.clear();
          for (var e in data) {
            final book = Book.fromJson(e as Map<String, dynamic>);
            _libraryBooks.add(book);
            _userRatings[book.id] = (e['rating'] as num).toDouble();
          }
        });
      }
    } catch (e) {
      debugPrint('Kullanıcı verisi yüklenirken hata: $e');
    }
  }

  void _runSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    if (!_recentSearches.contains(q)) {
      _recentSearches.insert(0, q);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _futureBooks = _repo.fetchBooks(q);
    });
  }

  static List<String> _parseAuthors(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      try {
        final d = jsonDecode(raw);
        if (d is List) return List<String>.from(d);
      } catch (_) {}
      return [raw];
    } else if (raw is List) {
      return List<String>.from(raw);
    }
    return [];
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(
            userId: widget.userId,
            userRatings:
            _userRatings.map((k, v) => MapEntry(k, v.toInt())),
            onAddToLibrary: (b) {
              if (!mounted) return;
              setState(() {
                _favoriteBooks.removeWhere((x) => x.id == b.id);
                _libraryBooks.add(b);
              });
            },
            onRate: (b, r) {
              if (!mounted) return;
              setState(() => _userRatings[b.id] = r.toDouble());
            },
          ),
        ),
      ).then((_) => setState(() => _selectedIndex = 1));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LibraryScreen(
            userId: widget.userId,
            userRatings:
            _userRatings.map((k, v) => MapEntry(k, v.toInt())),
            onRemoveFromLibrary: (b) {
              if (!mounted) return;
              setState(() {
                _libraryBooks.removeWhere((x) => x.id == b.id);
                _userRatings.remove(b.id);
              });
            },
            onRate: (b, r) {
              if (!mounted) return;
              setState(() => _userRatings[b.id] = r.toDouble());
            },
          ),
        ),
      ).then((_) => setState(() => _selectedIndex = 1));
    } else {
      setState(() => _selectedIndex = 1);
    }
  }

  void navigateToRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token')?.trim();
      if (token == null || token.isEmpty) return;

      final rawRecs = await RecommendationService.fetchRecommendations(
          token, widget.userId);
      final recBooks = rawRecs.map((rec) {
        return Book(
          id: rec['book_id'].toString(),
          title: rec['title'] ?? 'Başlık yok',
          authors: _parseAuthors(rec['authors']),
          thumbnailUrl: rec['thumbnail_url'] ?? '',
          publisher: rec['publisher'] ?? '',
          publishedDate: rec['published_date'] ?? '',
          description: rec['description'] ?? '',
          categories: [],
        );
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationsScreen(
            fetchRecommendations: fetchRecommendations,
            userRatings: <String, double>{},
            onToggleFavorite: (b) {
              setState(() {
                if (_favoriteBooks.any((x) => x.id == b.id))
                  _favoriteBooks.removeWhere((x) => x.id == b.id);
                else
                  _favoriteBooks.add(b);
              });
            },
            onAddToLibrary: (b) {
              setState(() {
                if (!_libraryBooks.any((x) => x.id == b.id))
                  _libraryBooks.add(b);
              });
            },
            onRate: (b, r) =>
                setState(() => _userRatings[b.id] = r.toDouble()),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Öneriler alınamadı: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Öneriler alınamadı")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final headerH = h * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              backgroundColor: Colors.deepPurple.shade200,
              expandedHeight: headerH,
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
                        Colors.deepPurple.shade100.withOpacity(0.8),
                        Colors.deepPurple.shade200,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.recommend, color: Colors.white),
                  onPressed: navigateToRecommendations,
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
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
              // —— Arama Kartı ——
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.05,
                  vertical: 12,
                ),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Kitap ara...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon:
                      Icon(Icons.search, color: AppColors.greyMedium),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _futureBooks = null;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () =>
                                _runSearch(_searchController.text),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (q) => _runSearch(q),
                  ),
                ),
              ),

              // —— Kitap Listesi veya Son Aramalar ——
              Expanded(
                child: _futureBooks == null
                    ? (_recentSearches.isEmpty
                // “Boş durum” — arama yok, geçmiş yok
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bir kitap arayın...',
                        style: AppTextStyle.BODY
                            .copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                )
                // Son aramalar varsa
                    : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: h * 0.02,
                  ),
                  itemCount: _recentSearches.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final term = _recentSearches[i];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(term),
                      onTap: () {
                        _searchController.text = term;
                        _runSearch(term);
                      },
                    );
                  },
                ))
                // Arama sonuçları varsa
                    : FutureBuilder<List<Book>>(
                  future: _futureBooks,
                  builder: (ctx, snap) {
                    if (snap.connectionState !=
                        ConnectionState.done) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                          child: Text('Hata: ${snap.error}',
                              style: AppTextStyle.BODY));
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
                      itemBuilder: (_, i) {
                        final b = books[i];
                        final rDouble = _userRatings[b.id] ?? 0.0;
                        final rInt = rDouble.toInt();
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(
                                userId: widget.userId,
                                book: b,
                                isFavorite: _favoriteBooks
                                    .any((x) => x.id == b.id),
                                isInLibrary: _libraryBooks
                                    .any((x) => x.id == b.id),
                                userRating: rInt,
                                onToggleFavorite: (bx) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (_favoriteBooks.any((x) =>
                                    x.id == bx.id))
                                      _favoriteBooks.removeWhere(
                                              (x) => x.id == bx.id);
                                    else
                                      _favoriteBooks.add(bx);
                                  });
                                },
                                onToggleLibrary: (bx) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (_libraryBooks.any((x) =>
                                    x.id == bx.id)) {
                                      _libraryBooks.removeWhere(
                                              (x) => x.id == bx.id);
                                      _userRatings.remove(bx.id);
                                    } else {
                                      _libraryBooks.add(bx);
                                    }
                                  });
                                },
                                onRate: (bx, rating) {
                                  if (!mounted) return;
                                  setState(() => _userRatings[
                                  bx.id] = rating.toDouble());
                                },
                              ),
                            ),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                            margin: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: b.thumbnailUrl.isNotEmpty
                                        ? Image.network(b.thumbnailUrl,
                                        fit: BoxFit.cover)
                                        : const Icon(Icons.book,
                                        size: 80,
                                        color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    b.title,
                                    style: AppTextStyle.BODY,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    b.authors.isNotEmpty
                                        ? b.authors.join(', ')
                                        : 'Bilinmeyen Yazar',
                                    style: AppTextStyle
                                        .MINI_DEFAULT_DESCRIPTION_TEXT
                                        .copyWith(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
                colors: [AppColors.logoDarkBlue, Colors.deepPurple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
            Text('Bookify', style: AppTextStyle.HEADING.copyWith(color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.deepPurple.shade200),
            title: Text('Ayarlar', style: AppTextStyle.BODY),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.deepPurple.shade200),
            title: Text('Hakkında', style: AppTextStyle.BODY),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.logoPink),
            title: Text('Çıkış Yap',
                style: AppTextStyle.BODY.copyWith(color: AppColors.logoPink)),
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen())),
          ),
          ListTile(
            leading: Icon(Icons.recommend, color: Colors.deepPurple.shade200),
            title: Text('Önerilen Kitaplar', style: AppTextStyle.BODY),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecommendationsScreen(
                    fetchRecommendations: fetchRecommendations,
                    userRatings: <String, double>{},
                    onToggleFavorite: (Book) {},
                    onAddToLibrary: (Book) {},
                    onRate: (Book, int) {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
