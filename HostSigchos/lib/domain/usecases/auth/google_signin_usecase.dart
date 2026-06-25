import '../../entities/usuario.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: Login con Google Sign-In
class GoogleSignInUseCase {
  GoogleSignInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Usuario> call() {
    return _repository.loginConGoogle();
  }
}
