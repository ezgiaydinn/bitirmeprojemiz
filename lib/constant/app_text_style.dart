// lib/constant/app_text_style.dart
import 'package:flutter/material.dart';
import 'package:bitirmeprojesi/constant/app_colors.dart';

class AppTextStyle {
  // Küçük açıklamalar için bold
  static const MINI_BOLD_DESCRIPTION_TEXT = TextStyle(
    fontSize: 13,
    color: Colors.black,
    letterSpacing: 3,
    fontWeight: FontWeight.w600,
  );

  // Ana buton yazısı
  static const MIDDLE_BUTTON_TEXT = TextStyle(
    fontSize: 20,
    letterSpacing: 5,
    color: Colors.white,
    fontWeight: FontWeight.w300,
  );

  // Küçük normal açıklama
  static const MINI_DESCRIPTION_TEXT = TextStyle(
    fontSize: 13,
    color: Colors.black87,
    letterSpacing: 3,
  );

  // Küçük default açıklama
  static const MINI_DEFAULT_DESCRIPTION_TEXT = TextStyle(
    fontSize: 13,
    color: Colors.black,
  );

  // Küçük bold açıklama
  static const MINI_DESCRIPTION_BOLD = TextStyle(
    fontSize: 13,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  // ——— Yeni eklediğimiz başlık stili ———
  static const HEADING = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.greyText,
    letterSpacing: 0,
  );

  // ——— Yeni eklediğimiz body/açıklama stili ———
  static const BODY = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
  );
}
