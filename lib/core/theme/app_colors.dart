import 'package:flutter/material.dart';

/// Màu sắc theo cấu hình Figma
class AppColors {
  AppColors._(); // Private constructor

  // Màu chữ
  static const Color text = Color(0xFF232323); // Black - Text - Light

  // Màu placeholder
  static const Color placeholder = Color(0xFFD9D9D9); // Gray - placeholder - Light

  // Màu chính cho nút
  static const Color primary = Color(0xFF26B89A); // Primary -btn - Light

  // Màu nền
  static const Color background = Color(0xFFF9F9F9); // Background - Light
  static const Color white = Color(0xFFFFFFFF); // White - Light (nền textfield)

  // Màu trạng thái
  static const Color error = Color(0xFFC62828); // Error - Light
  static const Color success = Color(0xFF1F9E85); // Success - Light
  static const Color saleHot = Color(0xFFFF6B5B); // Sale, Hot - Light

  // Shadow
  static const Color shadow = Color(0x1A000000); // Black với 10% opacity
}

