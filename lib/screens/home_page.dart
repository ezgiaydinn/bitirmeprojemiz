/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kitaptavsiyeapp/screens/login_screen.dart';
import 'package:kitaptavsiyeapp/screens/profile_screen.dart';
import 'package:kitaptavsiyeapp/components/rounded_button.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return const Center(
          child: Text(
            "Favorities Page",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case 1:
        return Column(
          children: [
            // Arama kutusu sabit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // KAYDIRILABİLİR İÇERİK
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Welcome to the Home Page!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D4856),
                      ),
                    ),
                    const SizedBox(height: 500), // örnek uzun içerik
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        return const Center(
          child: Text(
            "Search Page",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
*/

// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitirmeprojesi/models/book.dart';
import 'package:bitirmeprojesi/repositories/book_repository.dart';
import 'package:bitirmeprojesi/repositories/local_book_repository.dart';
import 'package:bitirmeprojesi/screens/book_detail_screen.dart';
import 'package:bitirmeprojesi/screens/favorites_screen.dart';
import 'package:bitirmeprojesi/screens/library_screen.dart';
import 'package:bitirmeprojesi/screens/recommendations_screen.dart';
// import 'package:bitirmeprojesi/screens/search_screen.dart';  // artık gerek yok
import 'package:bitirmeprojesi/screens/login_screen.dart';
import 'package:bitirmeprojesi/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageScreen extends StatefulWidget {
  final String name;
  final String userId;
  final BookRepository repo;

  HomePageScreen({
    Key? key,
    required this.name,
    required this.userId,
    BookRepository? repo,
  })  : repo = repo ?? LocalBookRepository(),
        super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late Future<List<Book>> _futureRecs;
  final List<Book> _favoriteBooks = [];
  final List<Book> _libraryBooks = [];
  final Map<String, int> _userRatings = {};
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _futureRecs = widget.repo.fetchRecommendations(query: 'flutter');
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      // Favoriler
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(
            userId: widget.userId,
            favoriteBooks: _favoriteBooks,
            onAddToLibrary: (book) {
              setState(() {
                _favoriteBooks.removeWhere((b) => b.id == book.id);
                _libraryBooks.add(book);
              });
            },
            userRatings: _userRatings,
            onRate: (b, r) => setState(() => _userRatings[b.id] = r),
          ),
        ),
      );
    } else if (index == 2) {
      // Kütüphane
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LibraryScreen(
            userId: widget.userId,
            libraryBooks: _libraryBooks,
            userRatings: _userRatings,
            onRemoveFromLibrary: (book) {
              setState(() {
                _libraryBooks.removeWhere((b) => b.id == book.id);
                _userRatings.remove(book.id);
              });
            },
            onRate: (b, r) => setState(() => _userRatings[b.id] = r),
          ),
        ),
      );
    } else {
      // Ana sayfa
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Kütüphane'),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _futureRecs,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Hata: ${snap.error}', style: GoogleFonts.openSans()));
          }
          final all = snap.data ?? [];
          final filtered = all.where((b) => !_libraryBooks.any((lb) => lb.id == b.id)).toList();
          final homeList = filtered.take(10).toList();
          final moreList = filtered.take(20).toList();
          return _buildHome(homeList, moreList);
        },
      ),
    );
  }

  Widget _buildHome(List<Book> homeList, List<Book> moreList) {
    return Column(
      children: [
        // Morlu üst header
        _buildHeader(),
        // Arama çubuğu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Kitap ara...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (q) => setState(() {
              _futureRecs = widget.repo.fetchRecommendations(query: q);
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Senin Kütüphanen'),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _libraryBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _libraryCard(_libraryBooks[i]),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Senin İçin Önerilenler'),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecommendationsScreen(
                              userId: widget.userId,
                              recommendations: moreList,
                              favoriteBooks: _favoriteBooks,
                              onToggleFavorite: (b) => setState(() {
                                if (_favoriteBooks.any((x) => x.id == b.id)) {
                                  _favoriteBooks.removeWhere((x) => x.id == b.id);
                                } else {
                                  _favoriteBooks.add(b);
                                }
                              }),
                              onAddToLibrary: (b) => setState(() {
                                _libraryBooks.add(b);
                                _favoriteBooks.removeWhere((x) => x.id == b.id);
                              }),
                              userRatings: _userRatings,
                              onRate: (b, r) => setState(() => _userRatings[b.id] = r),
                            ),
                          ),
                        ),
                        child: Text('Devamı', style: GoogleFonts.openSans()),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: homeList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _recommendationCard(homeList[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purpleAccent.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Merhaba, ${widget.name}!',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
        ),
      ),
    );
  }

  Drawer _buildDrawer() => Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Bookify',
              style: GoogleFonts.lato(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text('Settings', style: GoogleFonts.openSans()),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text('About', style: GoogleFonts.openSans()),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: Text('Logout', style: GoogleFonts.openSans(color: Colors.redAccent)),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          ),
        ),
      ],
    ),
  );

  Widget _libraryCard(Book book) {
    final fav = _favoriteBooks.any((b) => b.id == book.id);
    final rating = _userRatings[book.id] ?? 0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailScreen(
            userId: widget.userId,
            book: book,
            isFavorite: fav,
            isInLibrary: true,
            userRating: rating,
            onToggleFavorite: (b) {
              setState(() {
                if (fav) {
                  _favoriteBooks.removeWhere((x) => x.id == b.id);
                } else {
                  _favoriteBooks.add(b);
                }
              });
            },
            onToggleLibrary: (b) {
              setState(() {
                _libraryBooks.removeWhere((x) => x.id == b.id);
                _userRatings.remove(b.id);
                _favoriteBooks.removeWhere((x) => x.id == b.id);
              });
            },
            onRate: (b, r) => setState(() => _userRatings[b.id] = r),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 48, color: Colors.deepPurple),
                const SizedBox(height: 8),
                Text(book.title, textAlign: TextAlign.center, style: GoogleFonts.openSans()),
              ],
            ),
          ),
          if (rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  rating,
                      (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _recommendationCard(Book book) {
    final fav = _favoriteBooks.any((b) => b.id == book.id);
    final inLib = _libraryBooks.any((b) => b.id == book.id);
    final rating = _userRatings[book.id] ?? 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: book.thumbnailUrl.isNotEmpty
            ? Image.network(book.thumbnailUrl, width: 40, fit: BoxFit.cover)
            : const Icon(Icons.menu_book, color: Colors.purple),
        title: Text(book.title, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.authors.join(', '),
                style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey)),
            if (rating > 0)
              Row(
                children: List.generate(
                  rating,
                      (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
              color: fav ? Colors.redAccent : Colors.grey),
          onPressed: () => setState(() {
            if (fav) {
              _favoriteBooks.removeWhere((b) => b.id == book.id);
            } else {
              _favoriteBooks.add(book);
            }
          }),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              userId: widget.userId,
              book: book,
              isFavorite: fav,
              isInLibrary: inLib,
              userRating: rating,
              onToggleFavorite: (b) {
                setState(() {
                  if (fav) {
                    _favoriteBooks.removeWhere((x) => x.id == b.id);
                  } else {
                    _favoriteBooks.add(b);
                  }
                });
              },
              onToggleLibrary: (b) {
                setState(() {
                  if (inLib) {
                    _libraryBooks.removeWhere((x) => x.id == b.id);
                    _userRatings.remove(b.id);
                    _favoriteBooks.removeWhere((x) => x.id == b.id);
                  } else {
                    _libraryBooks.add(b);
                    _favoriteBooks.removeWhere((x) => x.id == b.id);
                  }
                });
              },
              onRate: (b, r) => setState(() => _userRatings[b.id] = r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(text,
        style: GoogleFonts.openSans(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
  );
}

