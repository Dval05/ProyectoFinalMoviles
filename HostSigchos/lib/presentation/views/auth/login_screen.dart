import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      var input = _emailController.text.trim();
      if (!input.contains('@')) {
        input = '$input@hostsigchos.com';
      }

      final success = await context.read<AuthViewModel>().login(
        input,
        _passwordController.text,
      );

      if (success && mounted) {
        final usuario = context.read<AuthViewModel>().usuarioActual;
        if (usuario != null) {
          _navegarPostLogin();
        }
      }
    }
  }

  void _navegarPostLogin() {
    if (kIsWeb) {
      Navigator.pushReplacementNamed(context, AppRoutes.propietarioDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _loginGoogle() async {
    final success = await context.read<AuthViewModel>().loginConGoogle();
    if (success && mounted) {
      final authVm = context.read<AuthViewModel>();
      // Si el usuario es solo de Google (sin contraseña), ofrecer vincular contraseña
      if (authVm.isUsuarioSoloGoogle) {
        _mostrarDialogoVincularPassword();
      } else {
        final usuario = authVm.usuarioActual;
        if (usuario != null) {
          _navegarPostLogin();
        }
      }
    }
  }

  Future<void> _loginBiometric() async {
    final success = await context.read<AuthViewModel>().loginConBiometria();
    if (success && mounted) {
      final usuario = context.read<AuthViewModel>().usuarioActual;
      if (usuario != null) {
        _navegarPostLogin();
      }
    }
  }

  void _mostrarDialogoVincularPassword() {
    final passwordDialogController = TextEditingController();
    final confirmDialogController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: ColorSchemeApp.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Crear contraseña',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Deseas crear una contraseña para también poder iniciar sesión con tu correo electrónico?',
                style: TextStyle(color: ColorSchemeApp.softGray, fontSize: 14),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Nueva contraseña',
                prefixIcon: Icons.lock_outline,
                controller: passwordDialogController,
                isPassword: true,
                validator: Validators.password,
              ),
              CustomTextField(
                label: 'Confirmar contraseña',
                prefixIcon: Icons.lock_outline,
                controller: confirmDialogController,
                isPassword: true,
                validator: (val) => Validators.confirmPassword(
                  val,
                  passwordDialogController.text,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              passwordDialogController.dispose();
              confirmDialogController.dispose();
              if (mounted) {
                final usuario = context.read<AuthViewModel>().usuarioActual;
                if (usuario != null) {
                  _navegarPostLogin();
                }
              }
            },
            child: const Text('Omitir'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dialogFormKey.currentState!.validate()) {
                final success = await context
                    .read<AuthViewModel>()
                    .vincularPassword(
                      passwordDialogController.text,
                    );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  passwordDialogController.dispose();
                  confirmDialogController.dispose();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Contraseña vinculada exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  final usuario = context.read<AuthViewModel>().usuarioActual;
                  if (usuario != null) {
                    _navegarPostLogin();
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSchemeApp.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Crear contraseña'),
          ),
        ],
      ),
    );
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
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 30,
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
                              color: ColorSchemeApp.error.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColorSchemeApp.error),
                            ),
                            child: Text(
                              authViewModel.errorMessage!,
                              style: const TextStyle(
                                color: ColorSchemeApp.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        CustomTextField(
                          label: 'Correo / Nombre de local',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
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
                              child: Text(
                                'O continúa con',
                                style: TextStyle(
                                  color: ColorSchemeApp.softGray,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loginGoogle,
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  size: 30,
                                  color: ColorSchemeApp.primaryGreen,
                                ),
                                label: const Text(
                                  'Google',
                                  style: TextStyle(
                                    color: ColorSchemeApp.darkText,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: ColorSchemeApp.divider,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (authViewModel.isBiometricAvailable) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    if (authViewModel.hasSavedCredentials) {
                                      _loginBiometric();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Inicia sesión con correo y contraseña primero para habilitar esta opción.',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.fingerprint,
                                    size: 30,
                                    color: ColorSchemeApp.primaryGreen,
                                  ),
                                  label: const Text(
                                    'Huella/Face ID',
                                    style: TextStyle(
                                      color: ColorSchemeApp.darkText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: ColorSchemeApp.divider,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: () {
                                context.read<AuthViewModel>().clearError();
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
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
            ],
          ),
        ),
      ),
    );
  }
}
