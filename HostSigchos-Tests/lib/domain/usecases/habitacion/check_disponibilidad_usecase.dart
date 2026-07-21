import '../../repositories/habitacion_repository.dart';

/// Caso de uso: Verificar disponibilidad de habitación
class CheckDisponibilidadUseCase {
  CheckDisponibilidadUseCase(this._repository);
  final HabitacionRepository _repository;

  Future<bool> call(
    String habitacionId,
    DateTime checkIn,
    DateTime checkOut,
    int cantidadSolicitada,
  ) {
    return _repository.verificarDisponibilidad(
      habitacionId,
      checkIn,
      checkOut,
      cantidadSolicitada,
    );
  }
}
