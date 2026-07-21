import '../../entities/reserva.dart';
import '../../repositories/reserva_repository.dart';

/// Caso de uso: Crear nueva reserva
class CrearReservaUseCase {
  CrearReservaUseCase(this._repository);
  final ReservaRepository _repository;

  Future<Reserva> call(Reserva reserva) {
    return _repository.crearReserva(reserva);
  }
}
