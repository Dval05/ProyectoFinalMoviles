import 'dart:typed_data';
import '../entities/usuario.dart';

/// Interfaz del repositorio de autenticación
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Usuario> loginConEmail(String email, String password);

  /// Registro con email, contraseña, cédula, edad, teléfono, ubicación y foto opcional
  Future<Usuario> registrarse({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  });

  /// Login con Google Sign-In
  Future<Usuario> loginConGoogle();

  /// Cerrar sesión
  Future<void> cerrarSesion();

  /// Obtener usuario actual
  Future<Usuario?> getUsuarioActual();

  /// Stream de cambios de autenticación
  Stream<Usuario?> get authStateChanges;

  /// Actualizar perfil del usuario
  Future<Usuario> actualizarPerfil({
    required String uid,
    String? nombre,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  });

  /// Vincular contraseña a cuenta de Google
  Future<void> vincularPasswordAGoogle({required String password});

  /// Enviar correo de verificación de email
  Future<void> enviarVerificacionEmail();

  /// Verificar si el email fue confirmado
  Future<bool> verificarEmailConfirmado();

  /// Enviar correo de recuperación de contraseña
  Future<void> enviarCorreoRecuperacionPassword(String email);



  /// Verificar si el usuario actual es solo de Google (sin contraseña vinculada)
  Future<bool> esUsuarioSoloGoogle();

  /// Eliminar cuenta de usuario
  Future<void> eliminarCuenta();
}
