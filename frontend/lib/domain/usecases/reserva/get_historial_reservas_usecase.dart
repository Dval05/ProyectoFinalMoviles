import '../../entities/reserva.dart';
import '../../repositories/reserva_repository.dart';

/// Caso de uso: Obtener historial de reservas del usuario
class GetHistorialReservasUseCase {
  final ReservaRepository _repository;
  GetHistorialReservasUseCase(this._repository);

  Future<List<Reserva>> call(String usuarioId) {
    return _repository.getReservasPorUsuario(usuarioId);
  }
}
