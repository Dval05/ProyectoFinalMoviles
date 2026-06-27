import '../../entities/promocion.dart';
import '../../repositories/promocion_repository.dart';

class GetPromocionesUseCase {
  GetPromocionesUseCase(this._repository);
  final PromocionRepository _repository;

  Future<List<Promocion>> call() async {
    return _repository.getPromociones();
  }
}
