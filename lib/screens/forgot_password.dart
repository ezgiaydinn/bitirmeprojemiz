// lib/screens/forgot_password.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'package:bitirmeprojesi/constant/app_text_style.dart';
import 'login_screen.dart';

// 🔄 API adresi sabiti
const String kBaseUrl = 'https://projembackend-production-4549.up.railway.app';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool   _isLoading = false;
  String _message   = '';

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message   = '';
    });

    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/api/auth/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (resp.statusCode == 200) {
        setState(() {
          _message = 'E-posta adresinize sıfırlama linki gönderildi.';
        });
      } else {
        final data = jsonDecode(resp.body);
        setState(() {
          _message = data['error'] ?? 'İşlem sırasında bir hata oluştu.';
        });
      }
    } catch (_) {
      setState(() {
        _message = 'Sunucuya ulaşılamadı. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size                = MediaQuery.of(context).size;
    final w                   = size.width;
    final h                   = size.height;
    final illustrationHeight  = h * 0.25;
    final logoSize            = w * 0.25;
    final padH                = w * 0.06;
    final padVsmall           = h * 0.02;
    final padVmedium          = h * 0.04;

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
                'assets/icons/forgot_password.svg',
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
              Text(
                'Şifremi Unuttum',
                style: AppTextStyle.HEADING,
              ),
              SizedBox(height: padVsmall),

              // Açıklama
              Text(
                'E-posta adresinizi girin, size bir sıfırlama linki gönderelim.',
                textAlign: TextAlign.center,
                style: AppTextStyle.BODY,
              ),
              SizedBox(height: padVmedium),

              // Kart içindeki form
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
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'E-posta',
                            prefixIcon: const Icon(Icons.mail_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'E-posta boş olamaz';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                .hasMatch(v)) {
                              return 'Geçerli bir e-posta girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: padVmedium),

                        SizedBox(
                          width: double.infinity,
                          height: h * 0.06,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  AppColors.white),
                            )
                                : Text(
                              'Gönder',
                              style: AppTextStyle.MIDDLE_BUTTON_TEXT
                                  .copyWith(
                                fontSize:    16,
                                fontWeight:  FontWeight.bold,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),

                        if (_message.isNotEmpty) ...[
                          SizedBox(height: padVsmall),
                          Text(
                            _message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _message.startsWith('E-posta')
                                  ? AppColors.logoMint
                                  : AppColors.logoPink,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: padVmedium),

              // Giriş ekranına dön
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
