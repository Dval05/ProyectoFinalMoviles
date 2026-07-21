import '../../domain/entities/habitacion.dart';
import '../../domain/repositories/habitacion_repository.dart';
import '../datasources/firebase/habitacion_datasource.dart';

class HabitacionRepositoryImpl implements HabitacionRepository {
  HabitacionRepositoryImpl(this._dataSource);
  final HabitacionDataSource _dataSource;

  @override
  Future<List<Habitacion>> getHabitacionesPorHosteria(String hosteriaId) async {
    return _dataSource.getHabitacionesPorHosteria(hosteriaId);
  }

  @override
  Future<List<Habitacion>> getTodasLasHabitaciones() async {
    return _dataSource.getTodasLasHabitaciones();
  }

  @override
  Future<Habitacion> getHabitacionById(String id) async {
    return _dataSource.getHabitacionById(id);
  }

  @override
  Future<bool> verificarDisponibilidad(
    String habitacionId,
    DateTime checkIn,
    DateTime checkOut,
    int cantidadSolicitada,
  ) async {
    return _dataSource.verificarDisponibilidad(
      habitacionId,
      checkIn,
      checkOut,
      cantidadSolicitada,
    );
  }
}
