import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/reserva.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/carrito_reserva_viewmodel.dart';
import '../../viewmodels/promocion_viewmodel.dart';
import '../../viewmodels/reserva_viewmodel.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class CheckoutReservaScreen extends StatefulWidget {
  const CheckoutReservaScreen({super.key});

  @override
  State<CheckoutReservaScreen> createState() => _CheckoutReservaScreenState();
}

class _CheckoutReservaScreenState extends State<CheckoutReservaScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromocionViewModel>().cargarPromociones();
    });
  }

  Future<void> _confirmarLoteReservas() async {
    final carritoVm = context.read<CarritoReservaViewModel>();
    final reservaVm = context.read<ReservaViewModel>();
    final authVm = context.read<AuthViewModel>();
    final promoVm = context.read<PromocionViewModel>();

    if (carritoVm.isEmpty) return;

    final usuario = authVm.usuarioActual;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reservar')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    bool allSuccess = true;
    final List<Reserva> reservasCreadas = [];

    for (final item in carritoVm.items) {
      final maxDesc = promoVm.obtenerDescuentoPara(item.habitacion.hosteriaId, item.habitacion.id);
      final precioOriginal = item.precioTotal;
      final precioConDescuento = maxDesc > 0 ? precioOriginal * (1 - maxDesc / 100) : precioOriginal;

      final reserva = Reserva(
        id: '',
        usuarioId: usuario.id,
        hosteriaId: item.habitacion.hosteriaId,
        habitacionId: item.habitacion.id,
        fechaCheckIn: item.fechaCheckIn,
        fechaCheckOut: item.fechaCheckOut,
        numHuespedes: item.numHuespedes,
        numHabitaciones: item.numHabitaciones,
        precioTotal: precioConDescuento,
        fechaCreacion: DateTime.now(),
        notas: item.notas,
        tipoHabitacion: item.habitacion.tipo,
        esParaOtraPersona: item.esParaOtraPersona,
        nombreOtraPersona: item.nombreOtraPersona,
      );

      final exito = await reservaVm.crearReserva(reserva);
      if (!exito) {
        allSuccess = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar reserva de ${item.habitacion.tipo}: ${reservaVm.errorMessage}')),
          );
        }
        break;
      } else if (reservaVm.reservaActual != null) {
        reservasCreadas.add(reservaVm.reservaActual!);
      }
    }

    if (allSuccess) {
      carritoVm.vaciarCarrito();
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.confirmacion, 
          arguments: reservasCreadas,
        );
      }
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carritoVm = context.watch<CarritoReservaViewModel>();
    final promoVm = context.watch<PromocionViewModel>();
    
    double totalOriginal = 0;
    double totalConDescuento = 0;
    
    for (final item in carritoVm.items) {
      totalOriginal += item.precioTotal;
      final desc = promoVm.obtenerDescuentoPara(item.habitacion.hosteriaId, item.habitacion.id);
      totalConDescuento += desc > 0 ? item.precioTotal * (1 - desc / 100) : item.precioTotal;
    }
    
    final hayDescuento = totalOriginal > totalConDescuento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Reserva'),
      ),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        child: carritoVm.isEmpty
            ? const Center(child: Text('El carrito está vacío'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carritoVm.items.length,
                      itemBuilder: (context, index) {
                        final item = carritoVm.items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('${item.numHabitaciones}x ${item.habitacion.tipo}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${AppDateUtils.formatearFechaCorta(item.fechaCheckIn)} - ${AppDateUtils.formatearFechaCorta(item.fechaCheckOut)}'),
                                if (item.esParaOtraPersona)
                                  Text('Para: ${item.nombreOtraPersona}', style: const TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.formatear(item.precioTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                InkWell(
                                  onTap: () => carritoVm.eliminarItem(item),
                                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total a pagar:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (hayDescuento)
                                    const Text(
                                      'Promociones aplicadas al carrito',
                                      style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (hayDescuento)
                                    Text(
                                      CurrencyFormatter.formatear(totalOriginal),
                                      style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                    ),
                                  Text(
                                    CurrencyFormatter.formatear(totalConDescuento),
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'Confirmar todas las reservas',
                            onPressed: _confirmarLoteReservas,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
