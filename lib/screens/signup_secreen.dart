// lib/screens/signup_secreen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../components/square_box.dart';
import '../constant/app_text_style.dart';
import '../constant/app_colors.dart';
import 'login_screen.dart';

const String kBaseUrl = 'https://projembackend-production-4549.up.railway.app';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey                 = GlobalKey<FormState>();
  final nameController           = TextEditingController();
  final emailController          = TextEditingController();
  final passwordController       = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool   _isLoading       = false;
  bool   _obscurePassword = true;
  bool   _obscureRepeat   = true;
  String errorMessage     = '';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> signupUser() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading   = true;
      errorMessage = '';
    });

    final name     = nameController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeat   = repeatPasswordController.text.trim();

    if (password != repeat) {
      setState(() {
        errorMessage = 'Şifreler eşleşmiyor.';
        _isLoading   = false;
      });
      return;
    }

    try {
      final resp = await http.post(
        Uri.parse('$kBaseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':     name,
          'email':    email,
          'password': password,
        }),
      );

      if (resp.statusCode == 201) {
        // 1) Başarı SnackBar’ı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kayıt başarılı! Lütfen e-postanı kontrol edip hesabını doğrula.',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 3),
          ),
        );
        // 2) Login sayfasına dön
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final data = jsonDecode(resp.body);
        setState(() {
          errorMessage = data['error'] ?? 'Kayıt yapılamadı.';
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'Sunucuya bağlanılamadı.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w    = size.width;
    final h    = size.height;

    final logoSize     = w * 0.25;
    final padH         = w * 0.06;
    final padVsmall    = h * 0.02;
    final padVmedium   = h * 0.04;
    final buttonHeight = h * 0.06;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: h - MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width:  logoSize,
                    height: logoSize,
                    fit:    BoxFit.cover,
                  ),
                ),
                SizedBox(height: padVmedium),

                // Form kartı
                Card(
                  elevation: 8,
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
                          // Kullanıcı adı
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Kullanıcı Adı',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Kullanıcı adı boş olamaz'
                                : null,
                          ),
                          SizedBox(height: padVsmall),

                          // E-posta
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'E-posta',
                              prefixIcon: const Icon(Icons.mail_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'E-posta boş olamaz';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                  .hasMatch(v)) {
                                return 'Geçerli bir e-posta girin';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: padVsmall),

                          // Şifre
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Şifre boş olamaz';
                              if (v.length < 6)
                                return 'En az 6 karakter girin';
                              return null;
                            },
                          ),
                          SizedBox(height: padVsmall),

                          // Şifre tekrar
                          TextFormField(
                            controller: repeatPasswordController,
                            obscureText: _obscureRepeat,
                            decoration: InputDecoration(
                              hintText: 'Şifreyi Tekrarla',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureRepeat
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscureRepeat = !_obscureRepeat),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Tekrar şifre boş olamaz';
                              if (v.length < 6)
                                return 'En az 6 karakter girin';
                              return null;
                            },
                          ),
                          SizedBox(height: padVsmall),

                          // Hata mesajı
                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: padVsmall),
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: AppColors.logoPink),
                              ),
                            ),

                          // Kayıt ol butonu
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : signupUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(AppColors.white),
                                ),
                              )
                                  : Text(
                                'KAYIT OL',
                                style: AppTextStyle.MIDDLE_BUTTON_TEXT.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

                // Veya ile devam et
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.greyMedium)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padH * 0.5),
                      child: Text(
                        "Veya ile devam et",
                        style: AppTextStyle.MINI_DESCRIPTION_TEXT
                            .copyWith(color: AppColors.greyText),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.greyMedium)),
                  ],
                ),
                SizedBox(height: padVsmall),

                // Google kutucuğu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SquareBox(imagePath: "assets/images/google.png"),
                  ],
                ),
                SizedBox(height: padVmedium),

                // Zaten hesabın var mı?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Zaten hesabın var mı? ",
                      style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        "Giriş Yap",
                        style: AppTextStyle.MINI_DESCRIPTION_TEXT.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padVmedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
