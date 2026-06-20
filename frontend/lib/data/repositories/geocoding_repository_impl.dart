import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/remote/geocoding_datasource.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingDataSource _dataSource;

  GeocodingRepositoryImpl(this._dataSource);

  @override
  Future<String> getDireccionDesdeCoordenadas(double lat, double lng) async {
    return await _dataSource.getDireccionDesdeCoordenadas(lat, lng);
  }

  @override
  Future<Map<String, double>> getCoordenadasDesdeDireccion(String direccion) async {
    return await _dataSource.getCoordenadasDesdeDireccion(direccion);
  }
}
