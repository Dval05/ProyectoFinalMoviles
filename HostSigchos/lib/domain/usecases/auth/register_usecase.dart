import 'dart:typed_data';
import '../../entities/usuario.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this.repository);
  final AuthRepository repository;

  Future<Usuario> call({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
    String rol = 'usuario',
  }) {
    return repository.registrarse(
      nombre: nombre,
      email: email,
      password: password,
      cedula: cedula,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      ubicacion: ubicacion,
      fotoBytes: fotoBytes,
      rol: rol,
    );
  }
}
