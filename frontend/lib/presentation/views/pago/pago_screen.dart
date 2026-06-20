import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/pago.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../viewmodels/pago_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';


class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tarjetaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String? _reservaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reservaId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _tarjetaController.dispose();
    _fechaController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _procesarPago() async {
    if (_formKey.currentState!.validate()) {
      if (_reservaId == null) return;

      final usuarioId = context.read<AuthViewModel>().usuarioActual?.id;
      if (usuarioId == null) return;

      // Obtener el monto (simulado, buscar de la reserva)
      final reservas = context.read<ReservaViewModel>().reservas;
      final reserva = reservas.firstWhere(
        (r) => r.id == _reservaId,
        orElse: () => context.read<ReservaViewModel>().reservaActual!,
      );

      final pago = Pago(
        id: '', // Se genera en BD
        reservaId: _reservaId!,
        usuarioId: usuarioId,
        monto: reserva.precioTotal,
        metodo: 'tarjeta',
        referencia: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        fechaPago: DateTime.now(),
      );

      final exito = await context.read<PagoViewModel>().procesarPago(pago);

      if (exito && mounted) {
        // Actualizamos estado de reserva a confirmada
        await context.read<ReservaViewModel>().cancelarReserva(''); // dummy para refresh (Ideal: updateStatus)
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago procesado con éxito'), backgroundColor: Colors.green),
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PagoViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Realizar Pago')),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos de la Tarjeta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Número de Tarjeta',
                  prefixIcon: Icons.credit_card,
                  controller: _tarjetaController,
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.length < 16 ? 'Número inválido' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'MM/AA',
                        prefixIcon: Icons.calendar_today,
                        controller: _fechaController,
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'CVV',
                        prefixIcon: Icons.security,
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        isPassword: true,
                        validator: (value) => value == null || value.length < 3 ? 'Invalido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Pagar Ahora',
                  onPressed: _procesarPago,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
