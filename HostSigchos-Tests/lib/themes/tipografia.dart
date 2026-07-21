import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'esquema_color.dart';

class TypographyApp {
  static TextTheme get textTheme {
    return GoogleFonts.outfitTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorSchemeApp.darkText,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorSchemeApp.darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorSchemeApp.darkText,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ColorSchemeApp.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ColorSchemeApp.darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColorSchemeApp.darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: ColorSchemeApp.softGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorSchemeApp.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
