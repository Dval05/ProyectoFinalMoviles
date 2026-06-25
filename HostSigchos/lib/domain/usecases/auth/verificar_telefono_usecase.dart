import '../../repositories/auth_repository.dart';

/// Caso de uso: Verificar teléfono mediante código SMS
class VerificarTelefonoUseCase {
  VerificarTelefonoUseCase(this._repository);
  final AuthRepository _repository;

  /// Envía código SMS al número de teléfono
  Future<void> enviarCodigo({
    required String telefono,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) {
    return _repository.enviarCodigoTelefono(
      telefono: telefono,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// Verifica el código SMS ingresado por el usuario
  Future<bool> verificarCodigo({
    required String verificationId,
    required String code,
  }) {
    return _repository.verificarCodigoTelefono(
      verificationId: verificationId,
      code: code,
    );
  }
}
