import 'dart:typed_data';
import '../../entities/usuario.dart';
import '../../repositories/auth_repository.dart';

class ActualizarPerfilUseCase {

  ActualizarPerfilUseCase(this._repository);
  final AuthRepository _repository;

  Future<Usuario> call({
    required String uid,
    String? nombre,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    return _repository.actualizarPerfil(
      uid: uid,
      nombre: nombre,
      cedula: cedula,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      ubicacion: ubicacion,
      fotoBytes: fotoBytes,
    );
  }
}
