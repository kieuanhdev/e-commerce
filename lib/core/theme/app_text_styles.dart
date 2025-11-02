import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles theo cấu hình Figma
class AppTextStyles {
  AppTextStyles._(); // Private constructor

  // Font family
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  // Headline - Light: 34px, Auto
  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.0,
      );

  // Headline 2: 24px, 120% (1.2)
  static TextStyle get headline2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.2,
      );

  // Headline 3: 18px, 22 line height (22/18 = 1.22)
  static TextStyle get headline3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 22 / 18,
      );

  // 16px regular
  static TextStyle get text16 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.0,
      );

  // 16px
  static TextStyle get text16Regular => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.0,
      );

  // 14px: 14px, 20 line height (20/14 = 1.43)
  static TextStyle get text14 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 20 / 14,
      );

  // Description: 14px, 150% line height (1.5)
  static TextStyle get description => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.5,
      );

  // 11px
  static TextStyle get text11 => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.text,
        height: 1.0,
      );
}

