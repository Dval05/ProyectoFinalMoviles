import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/habitacion_viewmodel.dart';
import '../../routes/app_routes.dart';
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
          context.read<HabitacionViewModel>().cargarHabitacionesPorHosteria(hosteriaId!);
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
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text('Error: ${viewModel.errorMessage}'))
              : viewModel.habitaciones.isEmpty
                  ? const Center(child: Text('No hay habitaciones disponibles'))
                  : RefreshIndicator(
                      onRefresh: () => viewModel.cargarHabitacionesPorHosteria(hosteriaId!),
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
