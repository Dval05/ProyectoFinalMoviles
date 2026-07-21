import '../../repositories/auth_repository.dart';

class EliminarCuentaUseCase {
  EliminarCuentaUseCase(this.repository);
  final AuthRepository repository;

  Future<void> call() async {
    return repository.eliminarCuenta();
  }
}
