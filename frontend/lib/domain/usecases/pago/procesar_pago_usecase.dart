import '../../entities/pago.dart';
import '../../repositories/pago_repository.dart';

/// Caso de uso: Procesar un pago
class ProcesarPagoUseCase {
  final PagoRepository _repository;
  ProcesarPagoUseCase(this._repository);

  Future<Pago> call(Pago pago) {
    return _repository.procesarPago(pago);
  }
}
