import 'dart:typed_data';
import '../../models/usuario_model.dart';
import '../firebase/auth_datasource.dart';

class MockAuthDataSource implements AuthDataSource {
  UsuarioModel? _usuarioActual;

  @override
  Stream<UsuarioModel?> get authStateChanges async* {
    yield _usuarioActual;
  }

  @override
  Future<UsuarioModel> loginConEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _usuarioActual = UsuarioModel(
      id: 'user123',
      nombre: 'Viajero Local',
      email: email,
      fechaRegistro: DateTime.now(),
      fotoUrl: 'https://ui-avatars.com/api/?name=Viajero+Local',
    );
    return _usuarioActual!;
  }

  @override
  Future<UsuarioModel> registrarse({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    int? edad,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _usuarioActual = UsuarioModel(
      id: 'user123',
      nombre: nombre,
      email: email,
      cedula: cedula,
      edad: edad,
      telefono: telefono,
      ubicacion: ubicacion,
      fechaRegistro: DateTime.now(),
    );
    return _usuarioActual!;
  }

  @override
  Future<UsuarioModel> loginConGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _usuarioActual = UsuarioModel(
      id: 'google123',
      nombre: 'Usuario Google',
      email: 'test@gmail.com',
      fechaRegistro: DateTime.now(),
      fotoUrl: 'https://ui-avatars.com/api/?name=Usuario+Google',
    );
    return _usuarioActual!;
  }

  @override
  Future<void> cerrarSesion() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _usuarioActual = null;
  }

  @override
  Future<UsuarioModel?> getUsuarioActual() async {
    return _usuarioActual;
  }
}
