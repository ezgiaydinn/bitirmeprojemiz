// lib/screens/login_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/app_text_style.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';
import 'forgot_password.dart';
import 'home_page.dart';
import 'signup_secreen.dart';

// 🔄 BASE_URL sabiti: import’lardan **sonra**,
const String kBaseUrl =
String.fromEnvironment(
  'API_URL',
  defaultValue:
  'https://projembackend-production-4549.up.railway.app',
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _emailController   = TextEditingController();
  final _passwordController= TextEditingController();

  bool   _isLoading        = false;
  bool   _obscurePassword  = true;
  String _errorMessage     = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':    _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data   = jsonDecode(response.body);
        final userId = data['user']['id'].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePageScreen(
              name:   _emailController.text.trim(),
              userId: userId,
            ),
          ),
        );
      } else {
        // 🔄 Sunucudan dönen `error` mesajını göster
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['error'] ?? 'Giriş başarısız.';
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage =
        'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.';
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
    final padVlarge    = h * 0.08;
    final buttonHeight = h * 0.06;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Column(
                children: [
                  SizedBox(height: padVlarge),
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
                                hintText:    'E-posta',
                                prefixIcon:  const Icon(Icons.mail_outline),
                                border:      OutlineInputBorder(
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
                            SizedBox(height: padVsmall),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText:   'Şifre',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                ),
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
                            SizedBox(height: padVsmall),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: Text(
                                  "Şifremi Unuttum?",
                                  style: AppTextStyle
                                      .MINI_BOLD_DESCRIPTION_TEXT,
                                ),
                              ),
                            ),
                            SizedBox(height: padVmedium),
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                  valueColor:
                                  AlwaysStoppedAnimation(
                                      AppColors.white),
                                )
                                    : Text(
                                  'Giriş Yap',
                                  style: AppTextStyle
                                      .MIDDLE_BUTTON_TEXT
                                      .copyWith(
                                    fontSize:    16,
                                    fontWeight:  FontWeight.bold,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: padVsmall),
                            AnimatedSwitcher(
                              duration:
                              const Duration(milliseconds: 300),
                              child: _errorMessage.isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                _errorMessage,
                                key: const ValueKey('error'),
                                style: TextStyle(
                                  color:   AppColors.logoPink,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: padVsmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Üye değil misin?",
                        style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const SignupScreen()),

                        ),
                        child: Text(
                          " Kayıt Ol",
                          style: AppTextStyle
                              .MINI_DESCRIPTION_TEXT
                              .copyWith(
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
      ),
    );
  }
}
