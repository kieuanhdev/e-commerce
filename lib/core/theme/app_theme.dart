import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_sizes.dart';

/// Cấu hình theme theo Figma
class AppTheme {
  AppTheme._(); // Private constructor

  /// Theme sáng (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSurface: AppColors.text,
        onError: AppColors.white,
      ),

      // Scaffold colors
      scaffoldBackgroundColor: AppColors.background,

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headline3,
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: AppSizes.iconMD,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: AppSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        color: AppColors.white,
        margin: const EdgeInsets.all(AppSizes.spacingSM),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppSizes.buttonElevation,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: AppTextStyles.text14,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLG,
            vertical: AppSizes.paddingMD,
          ),
          side: const BorderSide(
            color: AppColors.placeholder,
            width: AppSizes.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: AppTextStyles.text14,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMD,
            vertical: AppSizes.paddingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          textStyle: AppTextStyles.text14,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white, // Nền textfield theo Figma
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.placeholder,
            width: AppSizes.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.placeholder,
            width: AppSizes.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppSizes.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSizes.borderWidthThick,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSizes.borderWidthThick,
          ),
        ),
        hintStyle: AppTextStyles.text14.copyWith(
          color: AppColors.placeholder,
        ),
        labelStyle: AppTextStyles.text14,
        errorStyle: AppTextStyles.text11.copyWith(
          color: AppColors.error,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline,
        headlineLarge: AppTextStyles.headline2,
        headlineMedium: AppTextStyles.headline3,
        bodyLarge: AppTextStyles.text16,
        bodyMedium: AppTextStyles.text14,
        bodySmall: AppTextStyles.text11,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.text,
        size: AppSizes.iconMD,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.placeholder,
        thickness: AppSizes.dividerThickness,
        space: AppSizes.spacingMD,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppSizes.buttonElevation,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholder,
        selectedLabelStyle: AppTextStyles.text11,
        unselectedLabelStyle: AppTextStyles.text11,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: AppSizes.cardElevation * 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        titleTextStyle: AppTextStyles.headline3,
        contentTextStyle: AppTextStyles.text14,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: AppTextStyles.text14.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Theme tối (Dark Theme)
  static ThemeData get darkTheme {
    return lightTheme;
  }
}
