import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';

class HistorialReservasScreen extends StatefulWidget {
  const HistorialReservasScreen({super.key});

  @override
  State<HistorialReservasScreen> createState() =>
      _HistorialReservasScreenState();
}

class _HistorialReservasScreenState extends State<HistorialReservasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().usuarioActual;
      if (user != null) {
        context.read<ReservaViewModel>().cargarHistorial(user.id);
        // Verificar y notificar reservas pendientes
        _verificarPagosPendientes(user.id);
      }
    });
  }

  void _verificarPagosPendientes(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reservas = context.read<ReservaViewModel>().reservas;
      final pendientes = reservas
          .where((r) => r.estado == 'pendiente')
          .map(
            (r) => {
              'id': r.id,
              'nombreHosteria': r.nombreHosteria ?? 'la hostería',
            },
          )
          .toList();

      if (pendientes.isNotEmpty) {
        NotificationService().verificarYNotificarPagosPendientes(
          reservasPendientes: pendientes,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReservaViewModel>();
    final hosteriaVm = context.watch<HosteriaViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat(
      'dd MMM yyyy',
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationHistory),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.reservas.isEmpty
          ? Center(child: Text(l10n.noReservations))
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
                  
                  String nombreHosteria = reserva.nombreHosteria ?? 'Hostería';
                  if (reserva.nombreHosteria == null || reserva.nombreHosteria!.isEmpty) {
                    try {
                      nombreHosteria = hosteriaVm.hosterias.firstWhere((h) => h.id == reserva.hosteriaId).nombre;
                    } catch (_) {}
                  }
                  
                  final bool puedeCancelar = reserva.estado == 'pendiente';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.code}: ${reserva.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  _EstadoChip(estado: reserva.estado),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            "$nombreHosteria - ${reserva.tipoHabitacion ?? 'Habitación'}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: ColorSchemeApp.softGray,
                              ),
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
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: ColorSchemeApp.softGray,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${reserva.numHuespedes} ${l10n.guests}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.total}:',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                CurrencyFormatter.formatear(
                                  reserva.precioTotal,
                                ),
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
                                    AppRoutes.confirmacion,
                                    arguments: [reserva],
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColorSchemeApp.primaryGreen,
                                  side: const BorderSide(
                                    color: ColorSchemeApp.primaryGreen,
                                  ),
                                ),
                                child: const Text('Confirmar reserva'),
                              ),
                            ),
                          ],
                          if (reserva.estado != 'cancelada' &&
                              puedeCancelar) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.cancelReservation),
                                      content: Text(l10n.areYouSureCancel),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(l10n.noKeep),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text(
                                            l10n.yesCancel,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && context.mounted) {
                                    final success = await context
                                        .read<ReservaViewModel>()
                                        .cancelarReservaUsuario(reserva.id);
                                    if (success && context.mounted) {
                                      NotificationService().mostrarNotificacionLocal(
                                        titulo: l10n.bookingCancelledTitle,
                                        cuerpo: l10n.bookingCancelledBody,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.cancelSuccess),
                                        ),
                                      );
                                    } else if (context.mounted) {
                                      final error =
                                          context
                                              .read<ReservaViewModel>()
                                              .errorMessage ??
                                          'Error';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${l10n.cancelError}$error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  l10n.cancelReservation,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
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
  const _EstadoChip({required this.estado});
  final String estado;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completado':
        bgColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green[800]!;
      case 'cancelada':
        bgColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red[800]!;
      case 'en_revision':
        bgColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue[800]!;
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
        _getLocalizedEstado(context, estado).toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLocalizedEstado(BuildContext context, String estado) {
    final l10n = AppLocalizations.of(context)!;
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return l10n.confirmed;
      case 'completado':
        return l10n.completed;
      case 'cancelada':
        return l10n.cancelled;
      case 'en_revision':
        return l10n.inReview;
      default:
        return l10n.pending;
    }
  }
}
