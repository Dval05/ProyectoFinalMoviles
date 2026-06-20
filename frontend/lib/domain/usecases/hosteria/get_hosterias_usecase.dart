import '../../entities/hosteria.dart';
import '../../repositories/hosteria_repository.dart';

/// Caso de uso: Obtener lista de hosterías
class GetHosteriasUseCase {
  final HosteriaRepository _repository;
  GetHosteriasUseCase(this._repository);

  Future<List<Hosteria>> call() {
    return _repository.getHosterias();
  }
}
