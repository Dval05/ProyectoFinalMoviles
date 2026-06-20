import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../themes/esquema_color.dart';

class HistorialReservasScreen extends StatefulWidget {
  const HistorialReservasScreen({super.key});

  @override
  State<HistorialReservasScreen> createState() => _HistorialReservasScreenState();
}

class _HistorialReservasScreenState extends State<HistorialReservasScreen> {
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
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd MMM yyyy', 'es_ES');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.reservas.isEmpty
              ? const Center(child: Text('No tienes reservas aún'))
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = context.read<AuthViewModel>().usuarioActual;
                    if (user != null) {
                      await viewModel.cargarHistorial(user.id);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.reservas.length,
                    itemBuilder: (context, index) {
                      final reserva = viewModel.reservas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Código: ${reserva.id.substring(0, 8).toUpperCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  _EstadoChip(estado: reserva.estado),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                "${reserva.nombreHosteria ?? 'Hostería'} - ${reserva.tipoHabitacion ?? 'Habitación'}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: ColorSchemeApp.softGray),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${dateFormatter.format(reserva.fechaCheckIn)} al ${dateFormatter.format(reserva.fechaCheckOut)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: ColorSchemeApp.softGray),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${reserva.numHuespedes} Huéspedes',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    CurrencyFormatter.formatear(reserva.precioTotal),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSchemeApp.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (reserva.estado == 'pendiente') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.pago,
                                        arguments: reserva.id,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: ColorSchemeApp.primaryGreen),
                                    ),
                                    child: const Text('Realizar Pago'),
                                  ),
                                ),
                              ]
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

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completado':
        bgColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green[800]!;
        break;
      case 'cancelada':
        bgColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red[800]!;
        break;
      default: // pendiente
        bgColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
