import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../viewmodels/carrito_reserva_viewmodel.dart';
import '../../viewmodels/habitacion_viewmodel.dart';
import '../../widgets/habitacion_card.dart';

class HabitacionesListScreen extends StatefulWidget {
  const HabitacionesListScreen({super.key});

  @override
  State<HabitacionesListScreen> createState() => _HabitacionesListScreenState();
}

class _HabitacionesListScreenState extends State<HabitacionesListScreen> {
  String? hosteriaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hosteriaId == null) {
      hosteriaId = ModalRoute.of(context)?.settings.arguments as String?;
      if (hosteriaId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<HabitacionViewModel>().cargarHabitacionesPorHosteria(
            hosteriaId!,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HabitacionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitaciones'),
        actions: [
          Consumer<CarritoReservaViewModel>(
            builder: (context, carrito, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (carrito.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tu carrito está vacío')),
                        );
                        return;
                      }
                      Navigator.pushNamed(context, AppRoutes.checkout);
                    },
                  ),
                  if (carrito.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${carrito.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(child: Text('Error: ${viewModel.errorMessage}'))
          : viewModel.habitaciones.isEmpty
          ? const Center(child: Text('No hay habitaciones disponibles'))
          : RefreshIndicator(
              onRefresh: () =>
                  viewModel.cargarHabitacionesPorHosteria(hosteriaId!),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.habitaciones.length,
                itemBuilder: (context, index) {
                  final habitacion = viewModel.habitaciones[index];
                  return HabitacionCard(
                    habitacion: habitacion,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.crearReserva,
                        arguments: habitacion, // Pasamos la entidad completa
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
