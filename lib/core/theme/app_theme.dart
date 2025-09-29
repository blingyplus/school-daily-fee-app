import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

class AppTheme {
  // Color scheme for light theme
  static const Color _primaryColor = Color(0xFF2196F3);
  static const Color _primaryVariant = Color(0xFF1976D2);
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _secondaryVariant = Color(0xFF018786);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _errorColor = Color(0xFFB00020);
  static const Color _onPrimaryColor = Color(0xFFFFFFFF);
  static const Color _onSecondaryColor = Color(0xFF000000);
  static const Color _onSurfaceColor = Color(0xFF000000);
  static const Color _onBackgroundColor = Color(0xFF000000);
  static const Color _onErrorColor = Color(0xFFFFFFFF);

  // Color scheme for dark theme
  static const Color _darkPrimaryColor = Color(0xFF90CAF9);
  static const Color _darkPrimaryVariant = Color(0xFF1976D2);
  static const Color _darkSecondaryColor = Color(0xFF03DAC6);
  static const Color _darkSecondaryVariant = Color(0xFF03DAC6);
  static const Color _darkSurfaceColor = Color(0xFF121212);
  static const Color _darkBackgroundColor = Color(0xFF000000);
  static const Color _darkErrorColor = Color(0xFFCF6679);
  static const Color _darkOnPrimaryColor = Color(0xFF000000);
  static const Color _darkOnSecondaryColor = Color(0xFF000000);
  static const Color _darkOnSurfaceColor = Color(0xFFFFFFFF);
  static const Color _darkOnBackgroundColor = Color(0xFFFFFFFF);
  static const Color _darkOnErrorColor = Color(0xFF000000);

  // Custom colors
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFF9800);
  static const Color _infoColor = Color(0xFF2196F3);
  static const Color _greyColor = Color(0xFF9E9E9E);
  static const Color _lightGreyColor = Color(0xFFE0E0E0);
  static const Color _darkGreyColor = Color(0xFF424242);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        primaryContainer: _primaryVariant,
        secondary: _secondaryColor,
        secondaryContainer: _secondaryVariant,
        surface: _surfaceColor,
        background: _backgroundColor,
        error: _errorColor,
        onPrimary: _onPrimaryColor,
        onSecondary: _onSecondaryColor,
        onSurface: _onSurfaceColor,
        onBackground: _onBackgroundColor,
        onError: _onErrorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _greyColor,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: _lightGreyColor,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimaryColor,
        primaryContainer: _darkPrimaryVariant,
        secondary: _darkSecondaryColor,
        secondaryContainer: _darkSecondaryVariant,
        surface: _darkSurfaceColor,
        background: _darkBackgroundColor,
        error: _darkErrorColor,
        onPrimary: _darkOnPrimaryColor,
        onSecondary: _darkOnSecondaryColor,
        onSurface: _darkOnSurfaceColor,
        onBackground: _darkOnBackgroundColor,
        onError: _darkOnErrorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurfaceColor,
        foregroundColor: _darkOnSurfaceColor,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryColor,
          foregroundColor: _darkOnPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimaryColor,
          side: const BorderSide(color: _darkPrimaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkGreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkErrorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkErrorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: _darkOnPrimaryColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceColor,
        selectedItemColor: _darkPrimaryColor,
        unselectedItemColor: _darkGreyColor,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: _darkGreyColor,
        thickness: 1,
      ),
    );
  }

  // Custom color extensions
  static const Color successColor = _successColor;
  static const Color warningColor = _warningColor;
  static const Color infoColor = _infoColor;
  static const Color greyColor = _greyColor;
  static const Color lightGreyColor = _lightGreyColor;
  static const Color darkGreyColor = _darkGreyColor;
}
