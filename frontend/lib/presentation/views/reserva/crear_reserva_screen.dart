import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/habitacion.dart';
import '../../../domain/entities/reserva.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../themes/esquema_color.dart';

class CrearReservaScreen extends StatefulWidget {
  const CrearReservaScreen({super.key});

  @override
  State<CrearReservaScreen> createState() => _CrearReservaScreenState();
}

class _CrearReservaScreenState extends State<CrearReservaScreen> {
  Habitacion? _habitacion;
  DateTime? _fechaCheckIn;
  DateTime? _fechaCheckOut;
  int _numHuespedes = 1;
  final _notasController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _habitacion ??= ModalRoute.of(context)?.settings.arguments as Habitacion?;
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechas() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorSchemeApp.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorSchemeApp.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _fechaCheckIn = result.start;
        _fechaCheckOut = result.end;
      });
    }
  }

  int get _noches {
    if (_fechaCheckIn == null || _fechaCheckOut == null) return 0;
    // Si seleccionan el mismo día, cuenta como 1 noche mínimo
    final diff = _fechaCheckOut!.difference(_fechaCheckIn!).inDays;
    return diff == 0 ? 1 : diff;
  }

  double get _precioTotal {
    if (_habitacion == null) return 0;
    return _noches * _habitacion!.precioPorNoche;
  }

  void _confirmarReserva() async {
    if (_fechaCheckIn == null || _fechaCheckOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona las fechas de estadía')),
      );
      return;
    }

    final usuario = context.read<AuthViewModel>().usuarioActual;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reservar')),
      );
      return;
    }

    final reserva = Reserva(
      id: '', // Se genera en Firestore
      usuarioId: usuario.id,
      hosteriaId: _habitacion!.hosteriaId,
      habitacionId: _habitacion!.id,
      fechaCheckIn: _fechaCheckIn!,
      fechaCheckOut: _fechaCheckOut!,
      numHuespedes: _numHuespedes,
      precioTotal: _precioTotal,
      fechaCreacion: DateTime.now(),
      notas: _notasController.text.trim(),
      tipoHabitacion: _habitacion!.tipo,
    );

    final exito = await context.read<ReservaViewModel>().crearReserva(reserva);

    if (exito && mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.confirmacion,
        // Pasamos la reserva recién creada que quedó guardada en el ViewModel
      );
    } else if (mounted) {
      final error = context.read<ReservaViewModel>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Error al procesar reserva')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservaVm = context.watch<ReservaViewModel>();

    if (_habitacion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservar')),
        body: const Center(child: Text('Error: Datos de habitación no disponibles')),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Reserva'),
      ),
      body: LoadingOverlay(
        isLoading: reservaVm.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info de la habitación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorSchemeApp.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hotel, size: 40, color: ColorSchemeApp.primaryGreen),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _habitacion!.tipo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.formatear(_habitacion!.precioPorNoche)} / noche',
                            style: const TextStyle(color: ColorSchemeApp.darkGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Selección de fechas
              const Text('Fechas de Estadía', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              InkWell(
                onTap: _seleccionarFechas,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorSchemeApp.offWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: ColorSchemeApp.primaryGreen),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _fechaCheckIn != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppDateUtils.formatearFechaCorta(_fechaCheckIn!)} - ${AppDateUtils.formatearFechaCorta(_fechaCheckOut!)}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text('$_noches noche(s)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              )
                            : const Text('Seleccionar fechas'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Huéspedes
              const Text('Huéspedes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _numHuespedes > 1
                        ? () => setState(() => _numHuespedes--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: ColorSchemeApp.primaryGreen,
                  ),
                  Text('$_numHuespedes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _numHuespedes < _habitacion!.capacidad
                        ? () => setState(() => _numHuespedes++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: ColorSchemeApp.primaryGreen,
                  ),
                  const Spacer(),
                  Text('Máx. ${_habitacion!.capacidad}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              // Notas adicionales
              TextField(
                controller: _notasController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Peticiones especiales (opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Resumen de precio
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorSchemeApp.sandBeige.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total a pagar:'),
                        Text(
                          CurrencyFormatter.formatear(_precioTotal),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ColorSchemeApp.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Podrás realizar el pago en el siguiente paso',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              GradientButton(
                text: 'Confirmar y Proceder al Pago',
                onPressed: _confirmarReserva,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
