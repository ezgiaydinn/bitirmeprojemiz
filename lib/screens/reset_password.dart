// lib/screens/reset_password.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'login_screen.dart';

// 🔄 API adresi sabiti
const String kBaseUrl =
    'https://projembackend-production-4549.up.railway.app';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool   _isLoading = false;
  late String token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // deep-link ile gelen token’i alıyoruz
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    token = args['token'] as String;
  }

  // ✅ SnackBar ile geri bildirim gösterme
  void _showSnackBar(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitNewPassword() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/api/auth/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token':    token,
          'password': _passwordController.text.trim(),
        }),
      );

      if (resp.statusCode == 200) {
        _showSnackBar('Şifreniz başarıyla değiştirildi.', success: true);

        // 2 sn bekleyip Login ekranına dön
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final data = jsonDecode(resp.body);
        final error = data['error'] ?? 'Şifre güncellenemedi.';
        _showSnackBar(error);
      }
    } catch (e) {
      _showSnackBar('Sunucuya ulaşılamadı. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size               = MediaQuery.of(context).size;
    final w                  = size.width;
    final h                  = size.height;
    final illustrationHeight = h * 0.25;
    final logoSize           = w * 0.25;
    final padH               = w * 0.06;
    final padVsmall          = h * 0.02;
    final padVmedium         = h * 0.04;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustrasyon
              SvgPicture.asset(
                'assets/icons/reset_password.svg',
                height: illustrationHeight,
              ),
              SizedBox(height: padVmedium),

              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  width:  logoSize,
                  height: logoSize,
                  fit:    BoxFit.cover,
                ),
              ),
              SizedBox(height: padVmedium),

              // Başlık
              Text('Yeni Şifre Belirle', style: AppTextStyle.HEADING),
              SizedBox(height: padVsmall),

              // Açıklama
              Text(
                'Lütfen yeni şifrenizi girip onaylayın.',
                textAlign: TextAlign.center,
                style:     AppTextStyle.BODY,
              ),
              SizedBox(height: padVmedium),

              // Form kartı
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.all(padH),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Yeni şifre
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Yeni Şifre',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Şifre boş olamaz';
                            }
                            if (v.length < 6) {
                              return 'En az 6 karakter girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: padVmedium),

                        // Şifre onay
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Şifreyi Onayla',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: padVmedium),

                        // Gönder butonu
                        SizedBox(
                          width: double.infinity,
                          height: h * 0.06,
                          child: ElevatedButton(
                            onPressed:
                            _isLoading ? null : _submitNewPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation(AppColors.white),
                            )
                                : Text(
                              'Şifreyi Güncelle',
                              style: AppTextStyle.MIDDLE_BUTTON_TEXT
                                  .copyWith(
                                fontSize:     16,
                                fontWeight:   FontWeight.bold,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: padVmedium),

              // Login ekranına dön
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Text(
                  'Giriş Ekranına Dön',
                  style: AppTextStyle.BODY.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
