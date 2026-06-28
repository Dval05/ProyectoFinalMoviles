import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/remote/geocoding_datasource.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  GeocodingRepositoryImpl(this._dataSource);
  final GeocodingDataSource _dataSource;

  @override
  Future<String> getDireccionDesdeCoordenadas(double lat, double lng) async {
    return _dataSource.getDireccionDesdeCoordenadas(lat, lng);
  }

  @override
  Future<Map<String, double>> getCoordenadasDesdeDireccion(
    String direccion,
  ) async {
    return _dataSource.getCoordenadasDesdeDireccion(direccion);
  }
}
