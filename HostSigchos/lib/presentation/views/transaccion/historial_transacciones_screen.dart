import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';

class HistorialTransaccionesScreen extends StatefulWidget {
  const HistorialTransaccionesScreen({super.key});

  @override
  State<HistorialTransaccionesScreen> createState() => _HistorialTransaccionesScreenState();
}

class _HistorialTransaccionesScreenState extends State<HistorialTransaccionesScreen> {
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().usuarioActual;
      if (user != null) {
        context.read<ReservaViewModel>().cargarHistorial(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReservaViewModel>();
    final l10n = AppLocalizations.of(context)!;

    // Solo mostraremos como "transacciones" a aquellas reservas que no hayan sido canceladas,
    // o puedes mostrarlas todas con sus respectivos colores. Aquí mostraremos todas.
    final transacciones = viewModel.reservas;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentHistory), // 'Historial de Transacciones'
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transacciones.isEmpty
          ? Center(
              child: Text(
                l10n.noPaymentHistory,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final user = context.read<AuthViewModel>().usuarioActual;
                if (user != null) {
                  await viewModel.cargarHistorial(user.id);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transacciones.length,
                itemBuilder: (context, index) {
                  final transaccion = transacciones[index];
                  final isSuccess = transaccion.estado == 'confirmada';
                  final isCancelled = transaccion.estado == 'cancelada';

                  Color statusColor = Colors.orange;
                  IconData statusIcon = Icons.hourglass_bottom;
                  String estadoTexto = 'Pendiente';

                  if (isSuccess) {
                    statusColor = ColorSchemeApp.primaryGreen;
                    statusIcon = Icons.check_circle;
                    estadoTexto = 'Confirmada';
                  } else if (isCancelled) {
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    estadoTexto = 'Cancelada';
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.reference}: ${transaccion.id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormatter.format(transaccion.fechaCreacion),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estado: $estadoTexto',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatear(transaccion.precioTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: ColorSchemeApp.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
