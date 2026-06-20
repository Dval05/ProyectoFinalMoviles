import '../../repositories/reserva_repository.dart';

/// Caso de uso: Cancelar una reserva
class CancelarReservaUseCase {
  final ReservaRepository _repository;
  CancelarReservaUseCase(this._repository);

  Future<void> call(String reservaId) {
    return _repository.cancelarReserva(reservaId);
  }
}
