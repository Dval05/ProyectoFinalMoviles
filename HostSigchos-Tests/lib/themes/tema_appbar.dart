import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'esquema_color.dart';

class AppBarThemeApp {
  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      backgroundColor: ColorSchemeApp.white,
      foregroundColor: ColorSchemeApp.darkText,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        color: ColorSchemeApp.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: ColorSchemeApp.primaryGreen,
      ),
    );
  }
}
