import '../../entities/pago.dart';
import '../../repositories/pago_repository.dart';

/// Caso de uso: Obtener historial de pagos del usuario
class GetHistorialPagosUseCase {
  final PagoRepository _repository;
  GetHistorialPagosUseCase(this._repository);

  Future<List<Pago>> call(String usuarioId) {
    return _repository.getPagosPorUsuario(usuarioId);
  }
}
