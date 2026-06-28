import '../../repositories/pago_repository.dart';
import '../../repositories/reserva_repository.dart';

/// Caso de uso: Actualizar el estado de un pago
class ActualizarEstadoPagoUseCase {
  ActualizarEstadoPagoUseCase(this._pagoRepository, this._reservaRepository);
  final PagoRepository _pagoRepository;
  final ReservaRepository _reservaRepository;

  Future<void> call(
    String pagoId,
    String nuevoEstado, {
    String? reservaId,
  }) async {
    await _pagoRepository.actualizarEstadoPago(pagoId, nuevoEstado);
    if (reservaId != null) {
      await _reservaRepository.actualizarEstado(reservaId, nuevoEstado);
    }
  }
}
