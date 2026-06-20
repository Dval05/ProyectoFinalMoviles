import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/locale_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../../themes/esquema_color.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final usuario = authViewModel.usuarioActual;
    final localeVm = context.watch<LocaleViewModel>();
    final theme = Theme.of(context);

    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Sesión no iniciada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: ColorSchemeApp.lightGreen.withValues(alpha: 0.3),
                    backgroundImage: usuario.fotoUrl != null 
                        ? CachedNetworkImageProvider(usuario.fotoUrl!) 
                        : null,
                    child: usuario.fotoUrl == null
                        ? const Icon(Icons.person, size: 60, color: ColorSchemeApp.primaryGreen)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              usuario.nombre,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              usuario.email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ColorSchemeApp.softGray,
              ),
            ),
            const SizedBox(height: 48),
            
            _buildOpcionMenu(
              context,
              icon: Icons.history,
              title: 'Historial de Reservas',
              onTap: () => Navigator.pushNamed(context, AppRoutes.historialReservas),
            ),
            _buildOpcionMenu(
              context,
              icon: Icons.language,
              title: 'Idioma / Language',
              subtitle: localeVm.locale.languageCode == 'es' ? 'ESPAÑOL' : 'ENGLISH',
              onTap: () {
                context.read<LocaleViewModel>().toggleLanguage();
              },
            ),
            _buildOpcionMenu(
              context,
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionMenu(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: ColorSchemeApp.primaryGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
