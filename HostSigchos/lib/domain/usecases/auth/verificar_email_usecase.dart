import '../../repositories/auth_repository.dart';

/// Caso de uso: Enviar verificación de email y comprobar estado
class VerificarEmailUseCase {
  VerificarEmailUseCase(this._repository);
  final AuthRepository _repository;

  /// Envía el correo de verificación
  Future<void> enviar() {
    return _repository.enviarVerificacionEmail();
  }

  /// Comprueba si el email ya fue verificado
  Future<bool> verificar() {
    return _repository.verificarEmailConfirmado();
  }
}
