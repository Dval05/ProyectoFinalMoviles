import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _recuperarPassword() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await context.read<AuthViewModel>().recuperarPassword(
            _emailController.text.trim(),
          );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text('Si el correo está registrado, recibirás un enlace para restablecer tu contraseña. Revisa también tu bandeja de spam.'), 
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
            child: Stack(
              children: [
                const Positioned(
                  top: 8,
                  right: 8,
                  child: LanguageSelector(iconColor: Colors.white),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.lock_reset,
                              size: 64,
                              color: ColorSchemeApp.primaryGreen,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.forgotPassword,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: ColorSchemeApp.darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ingresa tu correo electrónico y te enviaremos un enlace para recuperar tu contraseña.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ColorSchemeApp.softGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
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
                              label: l10n.email,
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: l10n.confirm,
                              onPressed: _recuperarPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
