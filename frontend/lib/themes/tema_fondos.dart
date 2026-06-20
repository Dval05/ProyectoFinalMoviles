import 'package:flutter/material.dart';
import 'esquema_color.dart';

class BackgroundThemeApp {
  /// Gradiente principal verde montaña
  static BoxDecoration get mountainGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ColorSchemeApp.darkGreen,
          ColorSchemeApp.primaryGreen,
          ColorSchemeApp.lightGreen,
        ],
      ),
    );
  }

  /// Gradiente suave para pantallas de auth
  static BoxDecoration get authGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorSchemeApp.primaryGreen,
          ColorSchemeApp.primaryGreen.withValues(alpha: 0.8),
          ColorSchemeApp.offWhite,
        ],
        stops: const [0.0, 0.4, 1.0],
      ),
    );
  }

  /// Gradiente cálido tierra
  static BoxDecoration get warmGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorSchemeApp.sandBeige,
          ColorSchemeApp.offWhite,
        ],
      ),
    );
  }
}