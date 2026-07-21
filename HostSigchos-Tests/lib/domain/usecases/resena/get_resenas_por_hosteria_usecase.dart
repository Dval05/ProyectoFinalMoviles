import '../../entities/resena.dart';
import '../../repositories/resena_repository.dart';

class GetResenasPorHosteriaUseCase {
  const GetResenasPorHosteriaUseCase(this._repository);
  final ResenaRepository _repository;

  Stream<List<Resena>> call(String hosteriaId) {
    return _repository.getResenasPorHosteria(hosteriaId);
  }
}
