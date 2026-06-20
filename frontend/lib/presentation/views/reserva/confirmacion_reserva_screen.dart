import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../../themes/esquema_color.dart';

class ConfirmacionReservaScreen extends StatelessWidget {
  const ConfirmacionReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservaVm = context.watch<ReservaViewModel>();
    final reserva = reservaVm.reservaActual;

    return Scaffold(
      backgroundColor: ColorSchemeApp.offWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Ocultar botón atrás para forzar flujo
        title: const Text('Reserva Confirmada'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
              if (reserva != null)
                Text(
                  'Código: ${reserva.id.toUpperCase().substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ir a pantalla de pago, pasando el ID de la reserva
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.pago,
                      arguments: reserva?.id,
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
                  // Volver al home, el pago queda pendiente
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (route) => false);
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
