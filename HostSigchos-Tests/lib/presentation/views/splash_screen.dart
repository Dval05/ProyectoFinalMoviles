import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../themes/esquema_color.dart';
import '../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Simulamos tiempo mínimo de splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? user;
    try {
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Error verificando sesión: $e');
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.landing);
      return;
    }

    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();

    if (user != null) {
      // Comprobar si eligió mantener sesión
      const storage = FlutterSecureStorage();
      final keepSessionStr = await storage.read(key: 'keep_session');
      if (keepSessionStr == 'false') {
        // No quería mantener sesión -> cerramos y vamos a landing
        await FirebaseAuth.instance.signOut();
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.landing);
        return;
      }

      try {
        await authViewModel.checkCurrentSession().timeout(
          const Duration(seconds: 8),
        );
      } catch (e) {
        debugPrint('Error cargando sesión actual: $e');
      }
      if (!mounted) return;

      // Siempre ir a landing, independientemente de si hay sesión o no.
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder - Puedes reemplazar con una imagen real
              const Icon(
                Icons.landscape_rounded,
                size: 100,
                color: ColorSchemeApp.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'HostSigchos',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: ColorSchemeApp.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre Sigchos, vive la naturaleza',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ColorSchemeApp.softGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorSchemeApp.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
