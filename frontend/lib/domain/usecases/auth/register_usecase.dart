import 'dart:typed_data';
import '../../entities/usuario.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Usuario> call({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    int? edad,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) {
    return repository.registrarse(
      nombre: nombre,
      email: email,
      password: password,
      cedula: cedula,
      edad: edad,
      telefono: telefono,
      ubicacion: ubicacion,
      fotoBytes: fotoBytes,
    );
  }
}
