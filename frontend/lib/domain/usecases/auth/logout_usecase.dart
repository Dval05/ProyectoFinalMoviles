import '../../repositories/auth_repository.dart';

/// Caso de uso: Cerrar sesión
class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.cerrarSesion();
  }
}
