import '../../entities/usuario.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Login con email y contraseña
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Usuario> call(String email, String password) {
    return _repository.loginConEmail(email, password);
  }
}
