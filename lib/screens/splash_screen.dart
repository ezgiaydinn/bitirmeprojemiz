// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import '../constant/app_colors.dart';
import 'login_screen.dart';
import 'reset_password.dart';
import 'verify_email_screen.dart'; // ← ekledik

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double>   _animation;
  late final AppLinks            _appLinks;
  StreamSubscription<Uri?>?      _sub;

  bool _routedByDeepLink = false;

  @override
  void initState() {
    super.initState();

    // 1) Basit logo animasyonu
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween(begin: .8, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 2) Deep-link’leri dinlemeye başla
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // 2-A) Uygulama soğuk başlatıldıysa gelen link
    final Uri? initial = await _appLinks.getInitialLink();
    if (initial != null && _handleUri(initial)) return;

    // 2-B) Uygulama çalışırken gelen linkler
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  /// Eğer reset veya verify URI’si geldiyse true döner ve yönlendirir
  bool _handleUri(Uri? uri) {
    if (_routedByDeepLink || uri == null) return false;

    final scheme = uri.scheme;
    final host   = uri.host;
    final qp     = uri.queryParameters;

    // --- Reset şifre deep-link’i ---
    if (scheme == 'bookifyapp' &&
        host   == 'reset' &&
        qp.containsKey('token')) {

      final token = qp['token']!;
      _routedByDeepLink = true;
      _controller.dispose();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: RouteSettings(arguments: {'token': token}),
        ),
      );
      return true;
    }

    // --- E-posta doğrulama deep-link’i ---
    if (scheme == 'bookifyapp' &&
        host   == 'verify' &&
        qp.containsKey('token')) {

      final token = qp['token']!;
      _routedByDeepLink = true;
      _controller.dispose();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const VerifyEmailScreen(),
          settings: RouteSettings(arguments: {'token': token}),
        ),
      );
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w        = MediaQuery.of(context).size.width;
    final logoSize = w * .4;

    // 3) 3 sn sonra normal login’e git (deep-link yoksa)
    Future.delayed(const Duration(seconds: 3), () {
      if (_routedByDeepLink || !mounted) return;
      _controller.dispose();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
