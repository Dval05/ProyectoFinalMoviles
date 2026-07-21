import '../../repositories/reserva_repository.dart';

/// Caso de uso: Cancelar una reserva
class CancelarReservaUseCase {
  CancelarReservaUseCase(this._repository);
  final ReservaRepository _repository;

  Future<void> call(String reservaId) {
    return _repository.cancelarReserva(reservaId);
  }
}
