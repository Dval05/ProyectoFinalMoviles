import '../../entities/promocion.dart';
import '../../repositories/promocion_repository.dart';

class CrearPromocionUseCase {
  CrearPromocionUseCase(this._repository);
  final PromocionRepository _repository;

  Future<Promocion> call(Promocion promocion) async {
    return _repository.crearPromocion(promocion);
  }
}
