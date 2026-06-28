import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../themes/esquema_color.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pago_viewmodel.dart';

class HistorialPagosScreen extends StatefulWidget {
  const HistorialPagosScreen({super.key});

  @override
  State<HistorialPagosScreen> createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().usuarioActual;
      if (user != null) {
        context.read<PagoViewModel>().cargarHistorial(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PagoViewModel>();

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentHistory),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.pagos.isEmpty
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
                itemCount: viewModel.pagos.length,
                itemBuilder: (context, index) {
                  final pago = viewModel.pagos[index];
                  final isSuccess = pago.estado == 'completado';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? ColorSchemeApp.lightGreen.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.red.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSuccess ? Icons.check_circle : Icons.error,
                              color: isSuccess
                                  ? ColorSchemeApp.primaryGreen
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.reference}: ${pago.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormatter.format(pago.fechaPago),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.method}: ${pago.metodo}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatear(pago.monto),
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
