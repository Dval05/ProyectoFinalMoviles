import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/locale_viewmodel.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final usuario = authViewModel.usuarioActual;
    final localeVm = context.watch<LocaleViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Sesión no iniciada')),
      );
    }

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Fondo verde
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: const BoxDecoration(
                    color: ColorSchemeApp.primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Stack(
                        children: [
                          if (showBackButton)
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                l10n.profile,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Avatar e Info superpuesta
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: ColorSchemeApp.lightGreen.withValues(alpha: 0.3),
                          backgroundImage: usuario.fotoUrl != null
                              ? CachedNetworkImageProvider(usuario.fotoUrl!)
                              : null,
                          child: usuario.fotoUrl == null
                              ? Text(
                                  usuario.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: ColorSchemeApp.primaryGreen,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        usuario.nombre,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorSchemeApp.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorSchemeApp.softGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 140), // Espacio para que el Stack superpuesto respire

            // Tarjeta de Opciones Unificada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildOpcionMenu(
                      context,
                      icon: Icons.edit_outlined,
                      title: l10n.editProfile,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.editarPerfil),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.history_outlined,
                      title: l10n.reservationHistory,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.historialReservas),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.payment_outlined,
                      title: l10n.paymentHistory,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.historialTransacciones),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.language_outlined,
                      title: l10n.language,
                      subtitle: localeVm.locale.languageCode == 'es' ? 'ESPAÑOL' : 'ENGLISH',
                      onTap: () => context.read<LocaleViewModel>().toggleLanguage(),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.help_outline,
                      title: l10n.helpAndSupport,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ColorSchemeApp.lightGreen.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.support_agent_outlined, color: ColorSchemeApp.primaryGreen, size: 40),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    l10n.helpAndSupport,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: ColorSchemeApp.darkText),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.supportInfo,
                                    style: const TextStyle(fontSize: 15, color: ColorSchemeApp.softGray, height: 1.5),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.email_outlined, size: 18, color: ColorSchemeApp.primaryGreen),
                                            const SizedBox(width: 8),
                                            Text(AppConstants.supportEmail, style: const TextStyle(fontWeight: FontWeight.w600, color: ColorSchemeApp.primaryGreen)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.phone_outlined, size: 18, color: ColorSchemeApp.primaryGreen),
                                            const SizedBox(width: 8),
                                            Text('+${AppConstants.whatsappSupportNumber}', style: const TextStyle(fontWeight: FontWeight.w600, color: ColorSchemeApp.primaryGreen)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorSchemeApp.primaryGreen,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: Text(l10n.understood, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.description_outlined,
                      title: l10n.termsAndConditions,
                      onTap: () async {
                        final url = Uri.parse(AppConstants.termsUrl);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          debugPrint('No se pudo abrir Términos y Condiciones');
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 24, color: Color(0xFFF0F0F0)),
                    _buildOpcionMenu(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyPolicy,
                      onTap: () async {
                        final url = Uri.parse(AppConstants.privacyUrl);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          debugPrint('No se pudo abrir Políticas de Privacidad');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de Eliminar Cuenta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(AppConstants.accountDeletionUrl);
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('No se pudo abrir Solicitud de Eliminación');
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_remove_outlined, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        l10n.deleteAccount,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.open_in_new, color: Colors.red, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de Cerrar Sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: () async {
                  await authViewModel.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.splash,
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        l10n.logout,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionMenu(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ColorSchemeApp.primaryGreen, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ColorSchemeApp.darkText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorSchemeApp.softGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: ColorSchemeApp.softGray),
          ],
        ),
      ),
    );
  }
}
