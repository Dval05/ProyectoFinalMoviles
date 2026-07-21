import '../../repositories/auth_repository.dart';

class RecuperarPasswordUseCase {
  RecuperarPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email) async {
    return repository.enviarCorreoRecuperacionPassword(email);
  }
}
