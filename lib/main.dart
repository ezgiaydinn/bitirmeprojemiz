/*import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginScreen());
  }
}
*/
//import 'package:kitaptavsiyeapp/screens/splash_screen.dart';

/*import 'package:kitaptavsiyeapp/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, body: LoginScreen());
  }
}*/

import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

import 'package:bitirmeprojesi/screens/splash_screen.dart';
import 'package:bitirmeprojesi/screens/login_screen.dart';
import 'package:bitirmeprojesi/screens/forgot_password.dart';
import 'package:bitirmeprojesi/screens/reset_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    // Uygulama kapalıyken gelen link
    getInitialUri().then((uri) {
      if (uri != null) _handleUri(uri);
    });
    // Uygulama açıkken gelen linkler
    _sub = uriLinkStream.listen((uri) {
      if (uri != null) _handleUri(uri);
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  }

  void _handleUri(Uri uri) {
    // bookify://reset-password?token=xxx&id=123
    if (uri.host == 'reset-password') {
      final token = uri.queryParameters['token']!;
      final userId = uri.queryParameters['id']!;
      navigatorKey.currentState?.pushNamed(
        '/reset-password',
        arguments: {'token': token, 'userId': userId},
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/forgot-password': (ctx) => const ForgotPasswordScreen(),
        '/reset-password': (ctx) => const ResetPasswordScreen(),
        // diğer routeların varsa ekle
      },
    );
  }
}*/
