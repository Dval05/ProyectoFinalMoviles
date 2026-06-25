import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/entities/reserva.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pago_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
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

  String _metodoPago = 'tarjeta';
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

  Future<void> _procesarPago() async {
    if (_metodoPago == 'tarjeta' && !_formKey.currentState!.validate()) {
      return;
    }
    if (_reservaId == null) return;

    final usuarioId = context.read<AuthViewModel>().usuarioActual?.id;
    if (usuarioId == null) return;

    // Obtener el monto (simulado, buscar de la reserva)
    final reservas = context.read<ReservaViewModel>().reservas;
    final reserva = reservas.cast<Reserva>().firstWhere(
      (r) => r.id == _reservaId,
      orElse: () => context.read<ReservaViewModel>().reservaActual!,
    );

    final pago = Pago(
      id: '', // Se genera en BD
      reservaId: _reservaId!,
      usuarioId: usuarioId,
      monto: reserva.precioTotal,
      metodo: _metodoPago,
      referencia: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      fechaPago: DateTime.now(),
    );

    final exito = await context.read<PagoViewModel>().procesarPago(pago);

    if (exito && mounted) {
      // Para métodos no-tarjeta, mostrar mensaje de revisión
      if (_metodoPago != 'tarjeta') {
        _mostrarDialogoEnRevision();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago procesado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        if (!mounted) return;
        Navigator.pop(context); // Regresa a la pantalla anterior (historial)
      }
    }
  }

  void _mostrarDialogoEnRevision() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: Colors.orange,
            size: 40,
          ),
        ),
        title: const Text(
          'Pago en Revisión',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu pago ha sido registrado y se encuentra en revisión.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorSchemeApp.softGray),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Si el pago no se confirma dentro de 48 horas, el estado cambiará a pendiente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pop(
                  context,
                ); // Regresa a la pantalla anterior (historial)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSchemeApp.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PagoViewModel>().isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payment)),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.paymentMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_metodoPago),
                  initialValue: _metodoPago,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.payment,
                      color: ColorSchemeApp.primaryGreen,
                    ),
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
                  items: [
                    DropdownMenuItem(
                      value: 'tarjeta',
                      child: Text(l10n.creditDebitCard),
                    ),
                    DropdownMenuItem(
                      value: 'transferencia',
                      child: Text(l10n.bankTransfer),
                    ),
                    DropdownMenuItem(value: 'deuna', child: Text(l10n.deuna)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _metodoPago = val);
                  },
                ),

                // Aviso para métodos no-tarjeta
                if (_metodoPago != 'tarjeta') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Los pagos por ${_metodoPago == 'transferencia' ? 'transferencia' : 'Deuna'} quedan en estado "En Revisión" hasta ser verificados. Si no se confirman en 48h, pasarán a "Pendiente".',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                if (_metodoPago == 'tarjeta') ...[
                  Text(
                    l10n.cardDetails,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: l10n.cardNumber,
                    prefixIcon: Icons.credit_card,
                    controller: _tarjetaController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.length < 16 ? l10n.error : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: l10n.expiryDate,
                          prefixIcon: Icons.calendar_today,
                          controller: _fechaController,
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.error
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: l10n.cvv,
                          prefixIcon: Icons.security,
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          isPassword: true,
                          validator: (value) =>
                              value == null || value.length < 3
                              ? l10n.error
                              : null,
                        ),
                      ),
                    ],
                  ),
                ] else if (_metodoPago == 'transferencia') ...[
                  Text(
                    l10n.bankDetails,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorSchemeApp.primaryGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.transferInstructions,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.bankName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(l10n.accountType),
                        Text(l10n.accountNumber),
                        Text(l10n.ownerName),
                        Text(l10n.idNumber),
                      ],
                    ),
                  ),
                ] else if (_metodoPago == 'deuna') ...[
                  Text(
                    l10n.deuna,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorSchemeApp.primaryGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.deunaInstructions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: ColorSchemeApp.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.deunaNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                GradientButton(
                  text: _metodoPago == 'tarjeta'
                      ? l10n.payNow
                      : l10n.confirmPayment,
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
