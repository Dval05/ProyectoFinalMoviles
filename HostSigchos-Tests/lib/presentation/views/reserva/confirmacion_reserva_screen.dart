import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/reserva.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';

class ConfirmacionReservaScreen extends StatelessWidget {
  const ConfirmacionReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Capturar la lista de reservas desde los argumentos
    final reservas =
        ModalRoute.of(context)?.settings.arguments as List<Reserva>?;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Ocultar botón atrás para forzar flujo
        title: Text(AppLocalizations.of(context)!.bookingConfirmed),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: ColorSchemeApp.primaryGreen,
              ),
              const SizedBox(height: 24),
              const Text(
                'Reserva generada exitosamente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorSchemeApp.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Diríjase a WhatsApp para gestionar todo el proceso',
                style: TextStyle(color: ColorSchemeApp.softGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (reservas != null && reservas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.bookingCodes,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...reservas.map(
                  (r) => Text(
                    r.id.toUpperCase().substring(0, 8),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (reservas != null && reservas.isNotEmpty) {
                      final r = reservas.first;
                      final reservaId = r.id.substring(0, 8).toUpperCase();
                      final total = reservas.fold<double>(0, (sum, res) => sum + res.precioTotal);
                      final authVm = context.read<AuthViewModel>();
                      final hosteriaVm = context.read<HosteriaViewModel>();
                      final nombreCliente = authVm.usuarioActual?.nombre ?? 'Cliente';
                      
                      String hosteria = r.nombreHosteria ?? 'Hostería';
                      if (r.nombreHosteria == null || r.nombreHosteria!.isEmpty) {
                        try {
                          hosteria = hosteriaVm.hosterias.firstWhere((h) => h.id == r.hosteriaId).nombre;
                        } catch (_) {}
                      }
                      
                      final phone = AppConstants.whatsappSupportNumber;
                      final message = 'Hola, soy $nombreCliente. Me comunico a través de la aplicación HostSigchos para confirmar mi reserva con el código $reservaId para el hospedaje $hosteria por un total de \$${total.toStringAsFixed(2)}.';
                      final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                      
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                        // Actualizar el estado de la reserva(s) a 'en_revision' (Pendiente de revisión)
                        if (context.mounted) {
                          final reservaVm = context.read<ReservaViewModel>();
                          for (final r in reservas) {
                            await reservaVm.actualizarEstadoReserva(r.id, 'en_revision');
                          }
                        }
                      } catch (e) {
                        debugPrint('No se pudo abrir WhatsApp: $e');
                      }
                    }
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.historialReservas,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Dirigirse a WhatsApp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
