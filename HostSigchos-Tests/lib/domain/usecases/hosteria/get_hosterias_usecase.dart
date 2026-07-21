import '../../entities/hosteria.dart';
import '../../repositories/hosteria_repository.dart';

/// Caso de uso: Obtener lista de hosterías
class GetHosteriasUseCase {
  GetHosteriasUseCase(this._repository);
  final HosteriaRepository _repository;

  Future<List<Hosteria>> call() {
    return _repository.getHosterias();
  }
}
