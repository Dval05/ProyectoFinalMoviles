import '../../repositories/auth_repository.dart';

/// Caso de uso: Vincular contraseña a cuenta de Google
class VincularPasswordUseCase {
  VincularPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(String password) {
    return _repository.vincularPasswordAGoogle(password: password);
  }

  /// Verificar si el usuario actual es solo de Google (sin contraseña)
  Future<bool> esUsuarioSoloGoogle() {
    return _repository.esUsuarioSoloGoogle();
  }
}
