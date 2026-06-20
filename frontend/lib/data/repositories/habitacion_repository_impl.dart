import '../../domain/entities/habitacion.dart';
import '../../domain/repositories/habitacion_repository.dart';
import '../datasources/firebase/habitacion_datasource.dart';

class HabitacionRepositoryImpl implements HabitacionRepository {
  final HabitacionDataSource _dataSource;

  HabitacionRepositoryImpl(this._dataSource);

  @override
  Future<List<Habitacion>> getHabitacionesPorHosteria(String hosteriaId) async {
    return await _dataSource.getHabitacionesPorHosteria(hosteriaId);
  }

  @override
  Future<Habitacion> getHabitacionById(String id) async {
    return await _dataSource.getHabitacionById(id);
  }

  @override
  Future<bool> verificarDisponibilidad(
      String habitacionId, DateTime checkIn, DateTime checkOut) async {
    return await _dataSource.verificarDisponibilidad(habitacionId, checkIn, checkOut);
  }
}
