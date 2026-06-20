import 'dart:typed_data';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Stream<Usuario?> get authStateChanges => _authDataSource.authStateChanges;

  @override
  Future<Usuario> loginConEmail(String email, String password) async {
    return await _authDataSource.loginConEmail(email, password);
  }

  @override
  Future<Usuario> registrarse({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    int? edad,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    final model = await _authDataSource.registrarse(
      nombre: nombre,
      email: email,
      password: password,
      cedula: cedula,
      edad: edad,
      telefono: telefono,
      ubicacion: ubicacion,
      fotoBytes: fotoBytes,
    );
    return model;
  }

  @override
  Future<Usuario> loginConGoogle() async {
    return await _authDataSource.loginConGoogle();
  }

  @override
  Future<void> cerrarSesion() async {
    return await _authDataSource.cerrarSesion();
  }

  @override
  Future<Usuario?> getUsuarioActual() async {
    return await _authDataSource.getUsuarioActual();
  }

  @override
  Future<Usuario> actualizarPerfil(
      {String? nombre, String? telefono, Uint8List? fotoBytes}) {
    // Implementación pendiente
    throw UnimplementedError();
  }
}
