import 'package:flutter/material.dart';

import '../../../core/services/notification_service.dart';
import '../../../domain/entities/reserva.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';

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
        title: const Text('Reserva Confirmada'),
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
                '¡Reserva Creada Exitosamente!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorSchemeApp.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Hemos registrado tu solicitud de reserva en la hostería.',
                style: TextStyle(color: ColorSchemeApp.softGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (reservas != null && reservas.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Códigos de Reserva:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    // Ir a pantalla de pago, pasando la lista de reservas
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.pago,
                      arguments: reservas,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Proceder al Pago'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Programar notificación de recordatorio de pago
                  if (reservas != null && reservas.isNotEmpty) {
                    for (final r in reservas) {
                      NotificationService().programarNotificacionPagoPendiente(
                        reservaId: r.id,
                        nombreHosteria: r.nombreHosteria,
                      );
                    }

                    // Mostrar mensaje informativo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Te recordaremos realizar tu pago para confirmar la reserva.',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  // Ir al historial de reservas, el pago queda pendiente
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.historialReservas,
                  );
                },
                child: const Text('Pagar más tarde'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
