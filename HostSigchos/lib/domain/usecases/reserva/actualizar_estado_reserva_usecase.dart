import '../../repositories/reserva_repository.dart';

class ActualizarEstadoReservaUseCase {
  ActualizarEstadoReservaUseCase(this._repository);
  final ReservaRepository _repository;

  Future<void> call(String reservaId, String nuevoEstado) {
    return _repository.actualizarEstado(reservaId, nuevoEstado);
  }
}
