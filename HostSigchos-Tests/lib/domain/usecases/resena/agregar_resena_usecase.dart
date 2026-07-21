import '../../entities/resena.dart';
import '../../repositories/resena_repository.dart';

class AgregarResenaUseCase {
  const AgregarResenaUseCase(this._repository);
  final ResenaRepository _repository;

  Future<void> call(Resena resena) async {
    return _repository.agregarResena(resena);
  }
}
