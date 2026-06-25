import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/hosteria_viewmodel.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Cargar hosterías si no están cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hosteriaVm = context.read<HosteriaViewModel>();
      if (hosteriaVm.hosterias.isEmpty) {
        hosteriaVm.cargarHosterias();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hosteriaVm = context.watch<HosteriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Hosterías'),
        centerTitle: true,
      ),
      body: hosteriaVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(
                  AppConstants.sigchosLatitud,
                  AppConstants.sigchosLongitud,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hostsigchos',
                ),
                MarkerLayer(
                  markers: hosteriaVm.hosterias.map((hosteria) {
                    return Marker(
                      point: LatLng(hosteria.latitud, hosteria.longitud),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          _mostrarInfoHosteria(context, hosteria);
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: ColorSchemeApp.primaryGreen,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _mostrarInfoHosteria(BuildContext context, Hosteria hosteria) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hosteria.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorSchemeApp.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hosteria.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: ColorSchemeApp.softGray),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar modal
                    // Redirigir al detalle de la hosteria
                    context.read<HosteriaViewModel>().cargarHosteriaDetalle(
                      hosteria.id,
                    );
                    Navigator.pushNamed(
                      context,
                      AppRoutes.habitaciones,
                      arguments: hosteria.id,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver Detalles'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
