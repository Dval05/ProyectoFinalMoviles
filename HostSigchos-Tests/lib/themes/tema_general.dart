import 'package:flutter/material.dart';
import 'esquema_color.dart';
import 'tema_appbar.dart';
import 'tema_botones.dart';
import 'tipografia.dart';

class GeneralThemeApp {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorSchemeApp.primaryGreen,
        primary: ColorSchemeApp.primaryGreen,
        secondary: ColorSchemeApp.skyBlue,
        tertiary: ColorSchemeApp.goldenAccent,
        surface: ColorSchemeApp.pearlWhite,
        error: ColorSchemeApp.error,
      ),
      scaffoldBackgroundColor: ColorSchemeApp.pearlWhite,
      appBarTheme: AppBarThemeApp.appBarTheme,
      elevatedButtonTheme: ButtonThemeApp.elevatedButtonTheme,
      outlinedButtonTheme: ButtonThemeApp.outlinedButtonTheme,
      textButtonTheme: ButtonThemeApp.textButtonTheme,
      textTheme: TypographyApp.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorSchemeApp.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorSchemeApp.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorSchemeApp.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColorSchemeApp.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorSchemeApp.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorSchemeApp.error, width: 2),
        ),
        labelStyle: const TextStyle(color: ColorSchemeApp.softGray),
        hintStyle: TextStyle(
          color: ColorSchemeApp.softGray.withValues(alpha: 0.6),
        ),
        prefixIconColor: ColorSchemeApp.primaryGreen,
      ),
      cardTheme: CardThemeData(
        color: ColorSchemeApp.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorSchemeApp.white,
        selectedItemColor: ColorSchemeApp.primaryGreen,
        unselectedItemColor: ColorSchemeApp.softGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ColorSchemeApp.sandBeige,
        selectedColor: ColorSchemeApp.lightGreen,
        labelStyle: const TextStyle(
          color: ColorSchemeApp.darkText,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: ColorSchemeApp.divider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorSchemeApp.primaryGreen,
        foregroundColor: ColorSchemeApp.white,
        elevation: 4,
      ),
    );
  }
}
