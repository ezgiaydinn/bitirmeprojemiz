import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/square_box.dart';
import '../constant/app_text_style.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  String errorMessage = '';

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
      _isLoading = true;
      errorMessage = '';
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    if (password != repeatPassword) {
      setState(() {
        errorMessage = 'Şifreler eşleşmiyor.';
        _isLoading = false;
      });
      return;
    }

    const baseUrl =
        'https://projembackend-production-4549.up.railway.app';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // İsim
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Kullanıcı Adı',
                                prefixIcon:
                                const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Kullanıcı adı boş olamaz'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // E-posta
                            TextFormField(
                              controller: emailController,
                              keyboardType:
                              TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'E-posta',
                                prefixIcon:
                                const Icon(Icons.mail_outline),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'E-posta boş olamaz';
                                }
                                if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                    .hasMatch(v)) {
                                  return 'Geçerli bir e-posta girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Şifre
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Şifre',
                                prefixIcon:
                                const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
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
                            const SizedBox(height: 16),

                            // Şifreyi Tekrarla
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
                                  onPressed: () {
                                    setState(() {
                                      _obscureRepeat = !_obscureRepeat;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Tekrar şifre boş olamaz';
                                }
                                if (v.length < 6) {
                                  return 'En az 6 karakter girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Hata mesajı
                            if (errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 12),
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                      color: Colors.redAccent),
                                ),
                              ),

                            // Kayıt Ol Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                _isLoading ? null : signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF4A90E2),
                                  foregroundColor: Colors.white,
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
                                      Colors.white),
                                )
                                    : const Text(
                                  'KAYIT OL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Veya ile devam et
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                            color: Colors.grey[400], thickness: 0.5),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "Veya ile devam et",
                          style:
                          AppTextStyle.MINI_DESCRIPTION_TEXT,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                            color: Colors.grey[400], thickness: 0.5),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google ile devam
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SquareBox(
                          imagePath:
                          "assets/images/google.png"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Zaten hesabın var mı?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Zaten hesabın var mı? ",
                        style: AppTextStyle
                            .MINI_DEFAULT_DESCRIPTION_TEXT,
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                  const LoginScreen()),
                            ),
                        child: Text(
                          "Giriş Yap",
                          style: AppTextStyle
                              .MINI_DESCRIPTION_TEXT
                              .copyWith(
                            color: const Color(0xFF4A90E2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
