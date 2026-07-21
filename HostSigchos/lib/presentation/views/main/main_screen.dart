import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home/home_screen.dart';
import '../hosteria/hosterias_list_screen.dart';
import '../mapa/mapa_screen.dart';
import '../perfil/perfil_screen.dart';
import '../reserva/historial_reservas_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _promptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileIncomplete();
    });
  }

  void _checkProfileIncomplete() {
    if (_promptShown) return;
    
    final authVm = context.read<AuthViewModel>();
    final usuario = authVm.usuarioActual;
    
    if (usuario != null) {
      final isIncomplete = usuario.cedula == null || 
                           usuario.cedula!.isEmpty ||
                           usuario.telefono == null || 
                           usuario.telefono!.isEmpty ||
                           usuario.fechaNacimiento == null;
                           
      if (isIncomplete) {
        _promptShown = true;
        _showIncompleteProfileDialog();
      }
    }
  }

  void _showIncompleteProfileDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.incompleteProfileTitle),
          content: Text(l10n.incompleteProfileDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.later, style: const TextStyle(color: ColorSchemeApp.softGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.editarPerfil);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSchemeApp.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.completeNow),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final List<Widget> screens = [
      const HomeScreen(),
      const HosteriasListScreen(),
      const MapaScreen(),
      const HistorialReservasScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.chatbot),
        backgroundColor: ColorSchemeApp.primaryGreen,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ) : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: ColorSchemeApp.primaryGreen,
          unselectedItemColor: ColorSchemeApp.softGray,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n?.home ?? 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              activeIcon: const Icon(Icons.saved_search),
              label: l10n?.search ?? 'Búsqueda',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n?.map ?? 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
              label: l10n?.reservations ?? 'Reservas',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n?.profile ?? 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
