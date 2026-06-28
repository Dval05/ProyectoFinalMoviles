import 'dart:typed_data';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authDataSource);
  final AuthDataSource _authDataSource;

  @override
  Stream<Usuario?> get authStateChanges => _authDataSource.authStateChanges;

  @override
  Future<Usuario> loginConEmail(String email, String password) async {
    return _authDataSource.loginConEmail(email, password);
  }

  @override
  Future<Usuario> registrarse({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
    String rol = 'usuario',
  }) async {
    final model = await _authDataSource.registrarse(
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
    return model;
  }

  @override
  Future<Usuario> loginConGoogle() async {
    return _authDataSource.loginConGoogle();
  }

  @override
  Future<void> cerrarSesion() async {
    return _authDataSource.cerrarSesion();
  }

  @override
  Future<Usuario?> getUsuarioActual() async {
    return _authDataSource.getUsuarioActual();
  }

  @override
  Future<Usuario> actualizarPerfil({
    required String uid,
    String? nombre,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    return _authDataSource.actualizarPerfil(
      uid: uid,
      nombre: nombre,
      cedula: cedula,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      ubicacion: ubicacion,
      fotoBytes: fotoBytes,
    );
  }

  // ==================== NUEVOS MÉTODOS ====================

  @override
  Future<void> vincularPasswordAGoogle({required String password}) async {
    return _authDataSource.vincularPasswordAGoogle(password: password);
  }

  @override
  Future<void> enviarVerificacionEmail() async {
    return _authDataSource.enviarVerificacionEmail();
  }

  @override
  Future<bool> verificarEmailConfirmado() async {
    return _authDataSource.verificarEmailConfirmado();
  }

  @override
  Future<void> enviarCodigoTelefono({
    required String telefono,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    return _authDataSource.enviarCodigoTelefono(
      telefono: telefono,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  @override
  Future<bool> verificarCodigoTelefono({
    required String verificationId,
    required String code,
  }) async {
    return _authDataSource.verificarCodigoTelefono(
      verificationId: verificationId,
      code: code,
    );
  }

  @override
  Future<bool> esUsuarioSoloGoogle() async {
    return _authDataSource.esUsuarioSoloGoogle();
  }
}
