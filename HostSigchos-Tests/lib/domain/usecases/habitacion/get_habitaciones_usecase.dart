import '../../entities/habitacion.dart';
import '../../repositories/habitacion_repository.dart';

/// Caso de uso: Obtener habitaciones por hostería
class GetHabitacionesUseCase {
  GetHabitacionesUseCase(this._repository);
  final HabitacionRepository _repository;

  Future<List<Habitacion>> call(String hosteriaId) {
    return _repository.getHabitacionesPorHosteria(hosteriaId);
  }
}
