import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

/// DataSource Remoto que consume la API REST pública de Google Maps Geocoding
/// para cumplir con el requisito del proyecto: "Consumo de API REST"
class GeocodingDataSource {
  final http.Client client;

  GeocodingDataSource({http.Client? client}) : client = client ?? http.Client();

  /// Reverse Geocoding: De coordenadas GPS a dirección legible
  Future<String> getDireccionDesdeCoordenadas(double lat, double lng) async {
    if (AppConstants.googleMapsApiKey == 'TU_GOOGLE_MAPS_API_KEY') {
      // Simulación si la API key no está configurada aún (para desarrollo)
      await Future.delayed(const Duration(seconds: 1));
      return 'Sigchos, Provincia de Cotopaxi, Ecuador (Simulado)';
    }

    try {
      final uri = Uri.parse(
          '\${AppConstants.geocodingBaseUrl}?latlng=\$lat,\$lng&key=\${AppConstants.googleMapsApiKey}&language=es');

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else if (data['status'] == 'ZERO_RESULTS') {
          return 'Dirección no encontrada';
        } else {
          throw ServerFailure("Error de API: \${data['status']}");
        }
      } else {
        throw const ServerFailure('Error de servidor al contactar API de Geocoding');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure('Error de red al conectar con Google Geocoding');
    }
  }

  /// Geocoding: De dirección textual a coordenadas GPS
  Future<Map<String, double>> getCoordenadasDesdeDireccion(String direccion) async {
    if (AppConstants.googleMapsApiKey == 'TU_GOOGLE_MAPS_API_KEY') {
      // Retorna centro de Sigchos como fallback
      await Future.delayed(const Duration(seconds: 1));
      return {
        'lat': AppConstants.sigchosLatitud,
        'lng': AppConstants.sigchosLongitud
      };
    }

    try {
      final uri = Uri.parse(
          '\${AppConstants.geocodingBaseUrl}?address=\${Uri.encodeComponent(direccion)}&key=\${AppConstants.googleMapsApiKey}');

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': (location['lat'] as num).toDouble(),
            'lng': (location['lng'] as num).toDouble(),
          };
        } else {
          throw const ServerFailure('No se pudieron obtener coordenadas para esta dirección');
        }
      } else {
        throw const ServerFailure('Error de servidor API de Geocoding');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure('Error de red al conectar con Google Geocoding');
    }
  }
}
