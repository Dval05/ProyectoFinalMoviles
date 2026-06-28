import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    final authViewModel = context.read<AuthViewModel>();

    if (user != null) {
      await authViewModel.checkCurrentSession();
      if (!mounted) return;

      if (kIsWeb) {
        Navigator.pushReplacementNamed(context, AppRoutes.propietarioDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
