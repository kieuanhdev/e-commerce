import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow styles thống nhất cho ứng dụng
class AppShadows {
  AppShadows._(); // Private constructor

  // Small shadow - Đổ bóng nhỏ
  static const List<BoxShadow> small = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Medium shadow - Đổ bóng vừa
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Large shadow - Đổ bóng lớn
  static const List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Extra large shadow - Đổ bóng rất lớn
  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Card shadow - Đổ bóng cho card
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Button shadow - Đổ bóng cho nút
  static const List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Floating action button shadow - Đổ bóng cho FAB
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // AppBar shadow - Đổ bóng cho AppBar
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Bottom navigation bar shadow - Đổ bóng cho BottomNavBar
  static const List<BoxShadow> bottomNavBar = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, -2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Dialog shadow - Đổ bóng cho dialog
  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}

