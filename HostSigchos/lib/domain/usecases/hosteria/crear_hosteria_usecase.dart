import '../../entities/hosteria.dart';
import '../../repositories/hosteria_repository.dart';

class CrearHosteriaUseCase {
  CrearHosteriaUseCase(this._repository);
  final HosteriaRepository _repository;

  Future<void> call(Hosteria hosteria) {
    return _repository.crearHosteria(hosteria);
  }
}
