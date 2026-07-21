import '../../entities/hosteria.dart';
import '../../repositories/hosteria_repository.dart';

/// Caso de uso: Obtener detalle de una hostería
class GetHosteriaDetailUseCase {
  GetHosteriaDetailUseCase(this._repository);
  final HosteriaRepository _repository;

  Future<Hosteria> call(String id) {
    return _repository.getHosteriaById(id);
  }
}
