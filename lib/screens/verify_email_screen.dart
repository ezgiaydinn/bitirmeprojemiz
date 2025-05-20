import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constant/app_colors.dart';
import '../constant/app_text_style.dart';
import 'login_screen.dart';

const String kBaseUrl = 'https://projembackend-production-4549.up.railway.app';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late String token;
  String _message = 'Doğrulanıyor…';
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments
    as Map<String, String>;
    token = args['token']!;
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/api/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['ok'] == true) {
        setState(() => _message = 'E-posta başarıyla doğrulandı!');
      } else {
        setState(() => _message = data['error'] ?? 'Doğrulama başarısız.');
      }
    } catch (_) {
      setState(() => _message = 'Sunucuya ulaşılamadı.');
    } finally {
      setState(() => _loading = false);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: AppTextStyle.HEADING,
          ),
        ),
      ),
    );
  }
}
