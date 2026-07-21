import '../../repositories/auth_repository.dart';

/// Caso de uso: Cerrar sesión
class LogoutUseCase {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() {
    return _repository.cerrarSesion();
  }
}
