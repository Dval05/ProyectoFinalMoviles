import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/failures.dart';

/// DataSource Remoto que consume la API REST pública de Google Maps Geocoding
/// DataSource Remoto que consume la API REST de Nominatim (OpenStreetMap)
/// para cumplir con el requisito del proyecto: "Consumo de API REST"
class GeocodingDataSource {
  GeocodingDataSource({http.Client? client}) : client = client ?? http.Client();
  final http.Client client;

  /// Reverse Geocoding: De coordenadas GPS a dirección legible usando Nominatim (Gratis, sin API Key)
  Future<String> getDireccionDesdeCoordenadas(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await client.get(
        uri,
        headers: {
          'User-Agent': 'HostSigchosApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['display_name'] != null) {
          return data['display_name'];
        } else {
          return 'Dirección no encontrada';
        }
      } else {
        throw const ServerFailure(
          'Error de servidor al contactar API de Geocoding',
        );
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure('Error de red al conectar con OpenStreetMap');
    }
  }

  /// Geocoding: De dirección textual a coordenadas GPS usando Nominatim (Gratis, sin API Key)
  Future<Map<String, double>> getCoordenadasDesdeDireccion(
    String direccion,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(direccion)}&format=json&addressdetails=1&limit=1',
      );

      final response = await client.get(
        uri,
        headers: {
          'User-Agent': 'HostSigchosApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lng': double.parse(data[0]['lon']),
          };
        } else {
          throw const ServerFailure(
            'No se pudieron obtener coordenadas para esta dirección',
          );
        }
      } else {
        throw const ServerFailure('Error de servidor API de Geocoding');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const NetworkFailure('Error de red al conectar con OpenStreetMap');
    }
  }
}
