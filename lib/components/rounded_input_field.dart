import 'package:bitirmeprojesi/components/text_field_container.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isEmail;
  final bool isPassword;
  final TextEditingController? controller;
  final ValueChanged<String> onChange;
  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.onChange,
    required this.isEmail,
    required this.isPassword,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: controller,
        onChanged: onChange,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(icon, color: Color(0xFF3F3D56)),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            gapPadding: 1.0,
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          fillColor: Colors.grey.shade200,
        ),
      ),
    );
  }
}
