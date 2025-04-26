import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitirmeprojesi/components/rounded_button.dart';
import 'package:bitirmeprojesi/components/rounded_input_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(
          context,
        ).size; //bu tanımlamaya ve bu heigt*xx ifadelerine tekrar bak

    return Scaffold(
      body: Stack(
        children: [
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
              SizedBox(height: size.height * 0.08),
              SvgPicture.asset(
                "assets/icons/forgot_password.svg",
                height: size.height * 0.3,
              ),
              SizedBox(height: size.height * 0.05),
              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3D56),
                ),
              ),
              SizedBox(height: size.height * 0.015),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Text(
                  "We will send a password reset link to your email address.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              RoundedInputField(
                hintText: "Enter your email address",
                icon: Icons.mail,
                isEmail: true,
                isPassword: false,
                onChange: (value) {
                  // handle email input
                },
                controller: null,
              ),
              RoundedButton(
                text: "Send",
                color: Color(0xFFA2D9FF),
                press: () {
                  // send email logic
                },
              ),
              SizedBox(height: size.height * 0.04),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: Color(0xFF3F3D56),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
