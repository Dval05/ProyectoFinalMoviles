import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  /// Obtiene la ruta (Polyline) entre el origen y el destino usando OSRM.
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    // OSRM format: lon,lat
    final String url = 'http://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final geometry = routes[0]['geometry'];
            final coordinates = geometry['coordinates'] as List;
            
            return coordinates.map((coord) {
              // OSRM devuelve [lon, lat], lo invertimos a [lat, lon] para latlong2
              return LatLng(coord[1], coord[0]);
            }).toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error obteniendo la ruta: $e');
      return [];
    }
  }
}
