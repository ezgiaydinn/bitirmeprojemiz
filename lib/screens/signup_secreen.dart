import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/rounded_button.dart';
import '../components/rounded_input_field.dart';
import '../components/square_box.dart';
import '../constant/app_text_style.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  String errorMessage = '';

  Future<void> signupUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty) {
      setState(() {
        errorMessage = 'Tüm alanları doldurun.';
      });
      return;
    }

    if (password != repeatPassword) {
      setState(() {
        errorMessage = 'Şifreler eşleşmiyor.';
      });
      return;
    }

    final String baseUrl =
        'https://projembackend-production-4549.up.railway.app';

    try {
      final url = Uri.parse('$baseUrl/api/auth/signup');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        // Başarılı kayıt olduysa login ekranına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // API'den gelen hata mesajını oku
        final responseData = jsonDecode(response.body);
        setState(() {
          errorMessage = responseData['error'] ?? 'Kayıt yapılamadı.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Sunucuya bağlanılamadı.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                "assets/images/wave_üst.svg",
                height: 250,
                width: 100,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: 0.7,
              child: SvgPicture.asset(
                "assets/images/wave_alt.svg",
                height: 200,
                width: 50,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 200),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(20),
                    height: 470,
                    width: 340,
                    decoration: BoxDecoration(
                      color: const Color(0xffF3F3F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        RoundedInputField(
                          controller: nameController,
                          isEmail: false,
                          isPassword: false,
                          hintText: "Name",
                          icon: Icons.person,
                          onChange: (_) {},
                        ),
                        RoundedInputField(
                          controller: emailController,
                          isEmail: true,
                          isPassword: false,
                          hintText: "E-mail",
                          icon: Icons.mail,
                          onChange: (_) {},
                        ),
                        RoundedInputField(
                          controller: passwordController,
                          isEmail: false,
                          isPassword: true,
                          hintText: "Password",
                          icon: Icons.lock,
                          onChange: (_) {},
                        ),
                        RoundedInputField(
                          controller: repeatPasswordController,
                          isEmail: false,
                          isPassword: true,
                          hintText: "Repeat Password",
                          icon: Icons.lock_outline,
                          onChange: (_) {},
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 10),
                        RoundedButton(
                          text: "SIGN UP",
                          press: signupUser,
                          color: const Color(0xFFA2D9FF),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 50,
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or Continue with",
                        style: AppTextStyle.MINI_DESCRIPTION_TEXT,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        endIndent: 50,
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SquareBox(imagePath: "assets/images/google.png"),
                  SizedBox(width: 25),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Have an Account? ",
                    style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: AppTextStyle.MINI_DESCRIPTION_TEXT,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
    );
  }
}
