import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/rounded_button.dart';
import '../components/rounded_input_field.dart';
import '../constant/app_text_style.dart';
import '../screens/forgot_password.dart';
import '../screens/home_page.dart';
import '../screens/signup_secreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String errorMessage = '';

  Future<void> _login() async {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'E-posta ve şifre zorunludur.';
      });
      return;
    }

    final String baseUrl =
        'https://projembackend-production-4549.up.railway.app';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Backend'ten kullanıcı bilgisi bekliyoruz
        final userId = responseData['user']['id'].toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageScreen(name: email, userId: userId),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Giriş başarısız. Bilgileri kontrol edin.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Sunucuya ulaşılamadı. Lütfen internet bağlantınızı kontrol edin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              SizedBox(height: 150),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                width: 350,
                decoration: BoxDecoration(
                  color: Color(0xffF3F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    RoundedInputField(
                      isEmail: true,
                      isPassword: false,
                      hintText: "E-posta",
                      icon: Icons.mail,
                      onChange: (value) => email = value,
                      controller: null,
                    ),
                    RoundedInputField(
                      isEmail: false,
                      isPassword: true,
                      hintText: "Şifre",
                      icon: Icons.lock,
                      onChange: (value) => password = value,
                      controller: null,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Şifremi Unuttum?",
                        style: AppTextStyle.MINI_BOLD_DESCRIPTION_TEXT,
                      ),
                    ),
                    RoundedButton(
                      text: "Giriş Yap",
                      press: _login,
                      color: Color(0xFFA2D9FF),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Üye değil misin?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      " Kayıt Ol",
                      style: AppTextStyle.MINI_DESCRIPTION_TEXT,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
