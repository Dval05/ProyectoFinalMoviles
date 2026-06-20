import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../../core/utils/database_seeder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await context.read<AuthViewModel>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  void _loginGoogle() async {
    final success = await context.read<AuthViewModel>().loginConGoogle();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      body: LoadingOverlay(
        isLoading: authViewModel.isLoading,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.landscape_rounded,
                      size: 80,
                      color: ColorSchemeApp.primaryGreen,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenido a HostSigchos',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para continuar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorSchemeApp.softGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    if (authViewModel.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorSchemeApp.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorSchemeApp.error),
                        ),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: const TextStyle(color: ColorSchemeApp.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      label: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    
                    CustomTextField(
                      label: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navegar a recuperación de contraseña
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    GradientButton(
                      text: 'Iniciar Sesión',
                      onPressed: _login,
                    ),
                    
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O continúa con', style: TextStyle(color: ColorSchemeApp.softGray)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    OutlinedButton.icon(
                      onPressed: _loginGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: ColorSchemeApp.primaryGreen),
                      label: const Text('Google', style: TextStyle(color: ColorSchemeApp.darkText)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: ColorSchemeApp.divider),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: () {
                            context.read<AuthViewModel>().clearError();
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text('Regístrate aquí'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
              tooltip: 'Poblar Base de Datos (Mocks)',
              onPressed: () async {
                try {
                  await DatabaseSeeder.seedDatabase();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Base de datos poblada exitosamente!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al poblar BD: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    ),
  ),
    );
  }
}
