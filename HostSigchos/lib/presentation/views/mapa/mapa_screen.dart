import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
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
      if (hosteriaVm.todasHosterias.isEmpty) {
        hosteriaVm.cargarHosterias();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hosteriaVm = context.watch<HosteriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hotelMap),
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
                  markers: hosteriaVm.todasHosterias.map((hosteria) {
                    return Marker(
                      point: LatLng(hosteria.latitud, hosteria.longitud),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          _mostrarInfoHosteria(context, hosteria);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorSchemeApp.primaryGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home_work_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 6,
                              color: ColorSchemeApp.primaryGreen,
                            ),
                          ],
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
                  child: Text(AppLocalizations.of(context)!.reservationDetails),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Cerrar modal
                    final url = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${hosteria.latitud},${hosteria.longitud}',
                    );
                    try {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.error),
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorSchemeApp.primaryGreen,
                    side: const BorderSide(color: ColorSchemeApp.primaryGreen),
                  ),
                  icon: const Icon(Icons.directions),
                  label: Text(AppLocalizations.of(context)!.getDirections),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
