import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector.dart';
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
      String password = _passwordController.text;

      final success = await context.read<AuthViewModel>().login(
        input,
        password,
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
    // Cierra la sesión de autofill de Android antes de navegar; si el sistema
    // sigue mostrando el aviso de "guardar contraseña" cuando el árbol de
    // widgets del login se destruye, Flutter lanza
    // "_dependents.isEmpty is not true" al desmontar los campos.
    TextInput.finishAutofillContext();
    final hosteria = ModalRoute.of(context)?.settings.arguments;
    if (hosteria is Hosteria) {
      // Ponemos el Dashboard como base y luego la página de la hostería
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      Navigator.pushNamed(context, AppRoutes.hosteriaDetail, arguments: hosteria.id);
    } else {
      // Solo limpiamos la pila y vamos al Dashboard
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
    
    // Mostrar pop-up / notificacion de exito
    final authVm = context.read<AuthViewModel>();
    final nombre = authVm.usuarioActual?.nombre.split(' ').first ?? 'Usuario';
    NotificationService().mostrarNotificacionLocal(
      titulo: AppLocalizations.of(context)!.loginSuccessTitle,
      cuerpo: AppLocalizations.of(context)!.loginSuccessBody(nombre),
    );
  }

  Future<void> _loginGoogle() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.loginConGoogle();
    if (success && mounted) {
      final usuario = authViewModel.usuarioActual;
      if (usuario != null) {
        if (authViewModel.isUsuarioSoloGoogle) {
          _mostrarDialogoCrearPassword(context);
        } else {
          _navegarPostLogin();
        }
      }
    }
  }

  void _mostrarDialogoCrearPassword(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final l10n = AppLocalizations.of(ctx)!;
          return AlertDialog(
            title: Text(l10n.createPassword),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.createPasswordDescription),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.newPassword,
                    prefixIcon: Icons.lock_outline,
                    controller: passwordController,
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () {
                  Navigator.pop(ctx);
                  _navegarPostLogin();
                },
                child: Text(l10n.skip),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setState(() { isLoading = true; });
                    final linked = await context.read<AuthViewModel>().vincularPassword(passwordController.text);
                    if (linked && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.passwordLinked)),
                      );
                      _navegarPostLogin();
                    } else if (mounted) {
                      setState(() { isLoading = false; });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.read<AuthViewModel>().errorMessage ?? l10n.error)),
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.confirm),
              ),
            ],
          );
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.landing);
          },
        ),
        actions: const [
          LanguageSelector(iconColor: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: authViewModel.isLoading,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF308658), // Verde claro/brillante
                Color(0xFF1B5133), // Verde medio
                Color(0xFF0D2B1A), // Muy oscuro
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.landscape_rounded,
                          size: 100, // <-- Aquí puedes modificar el tamaño (dimensiones)
                          color: ColorSchemeApp.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.welcomeTo,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorSchemeApp.darkGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.signInToContinue,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorSchemeApp.softGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

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
                          const SizedBox(height: 12),
                        ],

                        CustomTextField(
                          label: l10n.email,
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l10n.error;
                            }
                            return null;
                          },
                        ),

                          CustomTextField(
                            label: l10n.password,
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            isPassword: true,
                            autofillHints: const [AutofillHints.password],
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n.error;
                              }
                              return null;
                            },
                          ),

                          Row(
                            children: [
                              Checkbox(
                                value: authViewModel.keepSession,
                                onChanged: (val) {
                                  if (val != null) {
                                    authViewModel.setKeepSession(value: val);
                                  }
                                },
                                activeColor: ColorSchemeApp.primaryGreen,
                                visualDensity: VisualDensity.compact,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => authViewModel.setKeepSession(value: !authViewModel.keepSession),
                                  child: const Text(
                                    'Mantener sesión activa',
                                    style: TextStyle(
                                      color: ColorSchemeApp.darkText, 
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: ColorSchemeApp.primaryGreen,
                                  padding: EdgeInsets.zero,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                child: Text(l10n.forgotPassword),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                        GradientButton(
                          text: l10n.login,
                          onPressed: _login,
                        ),


                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l10n.orContinueWith,
                                style: const TextStyle(color: ColorSchemeApp.softGray),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                                        SnackBar(
                                          content: Text(
                                            l10n.biometricSetupMessage,
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
                                  label: Text(
                                    l10n.biometricLogin,
                                    style: const TextStyle(
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

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.noAccount, style: const TextStyle(fontSize: 13)),
                            TextButton(
                              onPressed: () {
                                context.read<AuthViewModel>().clearError();
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: ColorSchemeApp.primaryGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              child: Text(l10n.registerHere),
                            ),
                          ],
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final url = Uri.parse('https://hostsigchos.web.app/terminos.html');
                                try {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  debugPrint('No se pudo abrir Términos y Condiciones');
                                }
                              },
                              child: const Text(
                                'Términos y Condiciones',
                                style: TextStyle(
                                  color: ColorSchemeApp.softGray,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Text(
                              '|',
                              style: TextStyle(color: ColorSchemeApp.softGray, fontSize: 12),
                            ),
                            TextButton(
                              onPressed: () async {
                                final url = Uri.parse('https://hostsigchos.web.app/politicas.html');
                                try {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  debugPrint('No se pudo abrir Políticas de Privacidad');
                                }
                              },
                              child: const Text(
                                'Políticas de Privacidad',
                                style: TextStyle(
                                  color: ColorSchemeApp.softGray,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
