import '../../entities/hosteria.dart';
import '../../repositories/hosteria_repository.dart';

class ActualizarHosteriaUseCase {
  ActualizarHosteriaUseCase(this._repository);
  final HosteriaRepository _repository;

  Future<void> call(Hosteria hosteria) {
    return _repository.actualizarHosteria(hosteria);
  }
}
