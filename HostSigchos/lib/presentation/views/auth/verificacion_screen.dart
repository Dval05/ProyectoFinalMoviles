import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final _codigoController = TextEditingController();
  bool _emailEnviado = false;
  bool _smsEnviado = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _enviarVerificacionEmail() async {
    final success = await context
        .read<AuthViewModel>()
        .enviarVerificacionEmail();
    if (success && mounted) {
      setState(() => _emailEnviado = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo de verificación enviado. Revisa tu bandeja de entrada.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _verificarEmail() async {
    final verified = await context.read<AuthViewModel>().verificarEmail();
    if (mounted) {
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Email verificado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El email aún no ha sido verificado. Revisa tu correo e intenta de nuevo.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _enviarCodigoSMS() async {
    final usuario = context.read<AuthViewModel>().usuarioActual;
    if (usuario?.telefono == null || usuario!.telefono!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se registró un número de teléfono. Puedes omitir este paso.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await context.read<AuthViewModel>().enviarCodigoTelefono(
      usuario.telefono!,
    );
    if (success && mounted) {
      setState(() => _smsEnviado = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código SMS enviado. Ingresa el código recibido.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _verificarCodigoSMS() async {
    if (_codigoController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un código de 6 dígitos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final verified = await context
        .read<AuthViewModel>()
        .verificarCodigoTelefono(
          _codigoController.text.trim(),
        );
    if (verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Teléfono verificado correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _continuar() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final usuario = authVm.usuarioActual;
    final tieneTelefono =
        usuario?.telefono != null && usuario!.telefono!.isNotEmpty;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        title: const Text('Verificación de Cuenta'),
        automaticallyImplyLeading: false,
      ),
      body: LoadingOverlay(
        isLoading: authVm.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono principal
              const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: ColorSchemeApp.primaryGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                'Verifica tu cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorSchemeApp.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Para mayor seguridad, verifica tu correo electrónico y número de teléfono.',
                style: TextStyle(color: ColorSchemeApp.softGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error message
              if (authVm.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorSchemeApp.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSchemeApp.error),
                  ),
                  child: Text(
                    authVm.errorMessage!,
                    style: const TextStyle(color: ColorSchemeApp.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ===== SECCIÓN EMAIL =====
              _buildSectionCard(
                icon: Icons.email_outlined,
                titulo: 'Verificación de Email',
                subtitulo: usuario?.email ?? '',
                isVerified: authVm.isEmailVerified,
                child: Column(
                  children: [
                    if (!authVm.isEmailVerified) ...[
                      if (!_emailEnviado)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _enviarVerificacionEmail,
                            icon: const Icon(Icons.send),
                            label: const Text('Enviar correo de verificación'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: ColorSchemeApp.primaryGreen,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        )
                      else ...[
                        const Text(
                          'Revisa tu bandeja de entrada y haz clic en el enlace de verificación.',
                          style: TextStyle(
                            color: ColorSchemeApp.softGray,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _verificarEmail,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Ya verifiqué mi email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorSchemeApp.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _enviarVerificacionEmail,
                          child: const Text('Reenviar correo'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== SECCIÓN TELÉFONO =====
              if (tieneTelefono) ...[
                _buildSectionCard(
                  icon: Icons.phone_outlined,
                  titulo: 'Verificación de Teléfono',
                  subtitulo: usuario.telefono!,
                  isVerified: authVm.isPhoneVerified,
                  child: Column(
                    children: [
                      if (!authVm.isPhoneVerified) ...[
                        if (!_smsEnviado)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _enviarCodigoSMS,
                              icon: const Icon(Icons.sms_outlined),
                              label: const Text('Enviar código SMS'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: ColorSchemeApp.primaryGreen,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          const Text(
                            'Ingresa el código de 6 dígitos que recibiste por SMS.',
                            style: TextStyle(
                              color: ColorSchemeApp.softGray,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _codigoController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              hintText: '------',
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: ColorSchemeApp.primaryGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _verificarCodigoSMS,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Verificar código'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorSchemeApp.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _enviarCodigoSMS,
                            child: const Text('Reenviar código'),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botón continuar
              const SizedBox(height: 16),
              GradientButton(
                text: authVm.isEmailVerified ? 'Continuar' : 'Omitir por ahora',
                onPressed: _continuar,
              ),
              if (!authVm.isEmailVerified) ...[
                const SizedBox(height: 8),
                const Text(
                  'Podrás verificar tu cuenta más tarde desde tu perfil.',
                  style: TextStyle(
                    color: ColorSchemeApp.softGray,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required bool isVerified,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isVerified ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVerified ? Icons.check_circle : icon,
                  color: isVerified
                      ? Colors.green
                      : ColorSchemeApp.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isVerified ? '✓ Verificado' : subtitulo,
                      style: TextStyle(
                        color: isVerified
                            ? Colors.green
                            : ColorSchemeApp.softGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }
}
