import '../../entities/promocion.dart';
import '../../repositories/promocion_repository.dart';

class ActualizarPromocionUseCase {
  ActualizarPromocionUseCase(this._repository);
  final PromocionRepository _repository;

  Future<void> call(Promocion promocion) async {
    return _repository.actualizarPromocion(promocion);
  }
}
