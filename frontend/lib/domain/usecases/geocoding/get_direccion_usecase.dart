import '../../repositories/geocoding_repository.dart';

/// Caso de uso: Obtener dirección desde coordenadas GPS (API REST)
class GetDireccionUseCase {
  final GeocodingRepository _repository;
  GetDireccionUseCase(this._repository);

  Future<String> call(double lat, double lng) {
    return _repository.getDireccionDesdeCoordenadas(lat, lng);
  }
}
