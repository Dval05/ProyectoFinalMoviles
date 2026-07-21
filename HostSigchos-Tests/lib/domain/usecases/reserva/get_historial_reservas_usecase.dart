import '../../entities/reserva.dart';
import '../../repositories/reserva_repository.dart';

/// Caso de uso: Obtener historial de reservas del usuario
class GetHistorialReservasUseCase {
  GetHistorialReservasUseCase(this._repository);
  final ReservaRepository _repository;

  Future<List<Reserva>> call(String usuarioId) {
    return _repository.getReservasPorUsuario(usuarioId);
  }
}
