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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFA2D9FF)),
              child: Text("Menu", style: TextStyle(fontSize: 24)),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
            ),
            const Divider(), // isteğe bağlı çizgi
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Wave background
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: SvgPicture.asset(
              "assets/images/wave_üst.svg",
              fit: BoxFit.cover,
              height: 200,
            ),
          ),

          // Menü Iconu (sol üst)
          Positioned(
            top: 40,
            left: 16,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),

          // Profil Iconu (sağ üst)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0, right: 5.0),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.grey, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
              ),
            ),
          ),

          // Sayfa içeriği
          Padding(
            padding: const EdgeInsets.only(top: 120, bottom: 60), // üst dalga + alt navbar boşluğu
            child: _buildPageContent(),
          ),
        ],
      ),

      // Alt Navigasyon Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
*/

/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Top Wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                "assets/images/wave_üst.svg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom Wave
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                "assets/images/wave_alt.svg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Welcome Text
                Text(
                  "Welcome to Bookify!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "Find your next favorite book.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                // Search Bar (Example)
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search books...",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Book Categories (Example Placeholder)
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Placeholder for categories
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      categoryCard("Fantasy"),
                      categoryCard("Romance"),
                      categoryCard("Thriller"),
                      categoryCard("Sci-Fi"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Recommended Books Header
                Text(
                  "Recommended for You",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Placeholder for recommended books
                Expanded(
                  child: ListView(
                    children: [
                      bookCard("The Silent Patient", "Alex Michaelides"),
                      bookCard("It Ends With Us", "Colleen Hoover"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Card Widget
  Widget categoryCard(String title) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFA2D9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Book Card Widget
  Widget bookCard(String title, String author) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffF3F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.book, color: Colors.blueGrey),
        title: Text(title),
        subtitle: Text(author),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';
import 'package:bitirmeprojesi/screens/profile_screen.dart';
import 'package:bitirmeprojesi/screens/search_screen.dart';

class HomePageScreen extends StatefulWidget {
  final String name;
  final String userId;

  const HomePageScreen({Key? key, required this.name, required this.userId})
    : super(key: key);

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
            "Favorites Page",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Welcome to Bookify!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 6,
              ),
              child: Text(
                "Find your next favorite book.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Categories",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                padding: const EdgeInsets.only(left: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  categoryCard("Fantasy"),
                  categoryCard("Romance"),
                  categoryCard("Thriller"),
                  categoryCard("Sci-Fi"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Recommended for You",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  bookCard("The Silent Patient", "Alex Michaelides"),
                  bookCard("It Ends With Us", "Colleen Hoover"),
                ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFA2D9FF)),
              child: Text("Menu", style: TextStyle(fontSize: 24)),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            const ListTile(leading: Icon(Icons.info), title: Text("About")),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Üst dalga
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              "assets/images/wave_üst.svg",
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Menü ikonu (sol üst)
          Positioned(
            top: 40,
            left: 16,
            child: Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
          ),

          // Profil ikonu (sağ üst)
          Scaffold(
            // Örnek: sağ üst köşede profil butonu
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(name: widget.name),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Sayfa içeriği
          Padding(
            padding: const EdgeInsets.only(top: 120, bottom: 60),
            child: _buildPageContent(),
          ),
        ],
      ),

      // Alt navigasyon bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // Kategori kartı
  static Widget categoryCard(String title) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFA2D9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Kitap kartı
  static Widget bookCard(String title, String author) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffF3F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.blueGrey),
        title: Text(title),
        subtitle: Text(author),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
