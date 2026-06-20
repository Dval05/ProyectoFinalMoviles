import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/geocoding_viewmodel.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Aquí idealmente integraríamos google_maps_flutter.
  // Por requerimiento del proyecto, consumimos la API REST de Geocoding.
  
  @override
  void initState() {
    super.initState();
    // Simular obtención de dirección para el cantón Sigchos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeocodingViewModel>().obtenerDireccion(-0.7022, -78.8828);
    });
  }

  @override
  Widget build(BuildContext context) {
    final geocodingVm = context.watch<GeocodingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa (Simulación)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 100, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Ubicación Central: Sigchos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (geocodingVm.isLoading)
                const CircularProgressIndicator()
              else if (geocodingVm.direccionActual != null)
                Text(
                  'API Geocoding (REST) resuelta:\n${geocodingVm.direccionActual}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                )
              else if (geocodingVm.errorMessage != null)
                Text('Error API: ${geocodingVm.errorMessage}', style: const TextStyle(color: Colors.red)),
                
              const SizedBox(height: 48),
              const Text(
                'Nota: La integración nativa de mapas (google_maps_flutter) requiere setup adicional de API Keys en AndroidManifest. Esta vista demuestra el consumo de la API REST requerida.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
