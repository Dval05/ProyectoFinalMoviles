import '../../repositories/habitacion_repository.dart';

/// Caso de uso: Verificar disponibilidad de habitación
class CheckDisponibilidadUseCase {
  final HabitacionRepository _repository;
  CheckDisponibilidadUseCase(this._repository);

  Future<bool> call(String habitacionId, DateTime checkIn, DateTime checkOut) {
    return _repository.verificarDisponibilidad(habitacionId, checkIn, checkOut);
  }
}
