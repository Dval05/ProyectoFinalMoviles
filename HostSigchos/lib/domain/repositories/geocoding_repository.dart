/// Interfaz del repositorio de geocoding (API REST)
abstract class GeocodingRepository {
  /// Obtener dirección a partir de coordenadas (reverse geocoding)
  Future<String> getDireccionDesdeCoordenadas(double lat, double lng);

  /// Obtener coordenadas a partir de una dirección
  Future<Map<String, double>> getCoordenadasDesdeDireccion(String direccion);
}
