// lib/screens/profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';
import 'package:bitirmeprojesi/screens/profileedit_screen.dart';
import 'package:bitirmeprojesi/screens/home_page.dart';
import 'package:bitirmeprojesi/screens/favorites_screen.dart';
import 'package:bitirmeprojesi/screens/library_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String name;

  const ProfileScreen({
    Key? key,
    required this.userId,
    required this.name,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  String email = '';
  bool isLoading = true;

  int _currentIndex = 1; // 0: Favoriler, 1: Ana Sayfa, 2: Kütüphane

  @override
  void initState() {
    super.initState();
    name = widget.name;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    const baseUrl = 'https://projembackend-production-4549.up.railway.app';
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body)['user'];
        setState(() {
          name = user['name'];
          email = user['email'];
        });
      }
    } catch (_) {
      // ignore errors
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FavoritesScreen(
              userId: widget.userId,
              onAddToLibrary: (_) {},
              userRatings: {},
              onRate: (_, __) {},
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePageScreen(
              name: widget.name,
              userId: widget.userId,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LibraryScreen(
              userId: widget.userId,
              userRatings: {}, // Şu an profilden kütüphane puanını değiştirmiyoruz
              onRate: (book, rating) {
                // Profil ekranından rating değişimi genelde olmaz,
                // istersen buradan da backend’e POST atabilirsin
              },
              onRemoveFromLibrary: (book) {
                // Profil ekranından kütüphaneden çıkarma yapılırsa
                // listeyi güncellemek için stub bırakıyoruz
              },
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final headerHeight = h * 0.30;
    final avatarRadius = w * 0.15;
    final padH = w * 0.06;
    final padVsmall = h * 0.02;
    final padVmedium = h * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor:
            AlwaysStoppedAnimation(AppColors.accent),
          ),
        )
            : Column(
          children: [
            Container(
              width: double.infinity,
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.8),
                    AppColors.accent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: const AssetImage(
                      'assets/images/avatar.png',
                    ),
                  ),
                  SizedBox(height: padVsmall),
                  Text(
                    name,
                    style: AppTextStyle.HEADING.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: padVsmall * 0.5),
                  Text(
                    email,
                    style: AppTextStyle.BODY.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: padVmedium),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: padH),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.edit,
                      text: 'Profil Düzenle',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(
                                  userId: widget.userId,
                                ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                        height: 0, indent: 72),
                    _buildTile(
                      icon: Icons.settings,
                      text: 'Ayarlar',
                      onTap: () {},
                    ),
                    const Divider(
                        height: 0, indent: 72),
                    _buildTile(
                      icon: Icons.help_outline,
                      text: 'Yardım',
                      onTap: () {},
                    ),
                    const Divider(
                        height: 0, indent: 72),
                    _buildTile(
                      icon: Icons.logout,
                      text: 'Çıkış Yap',
                      iconColor: AppColors.logoPink,
                      textColor:
                      AppColors.logoPink,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const LoginScreen(),
                          ),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: padVmedium),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.logoPink,
        unselectedItemColor: AppColors.greyText,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Kütüphane',
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final horizontalPadding =
        MediaQuery.of(context).size.width * 0.05;
    return ListTile(
      contentPadding:
      EdgeInsets.symmetric(horizontal: horizontalPadding),
      leading:
      Icon(icon, color: iconColor ?? AppColors.accent),
      title: Text(
        text,
        style: AppTextStyle.BODY.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: iconColor ?? AppColors.accent,
      ),
      onTap: onTap,
    );
  }
}