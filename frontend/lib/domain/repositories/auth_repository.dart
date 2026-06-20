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
    int? edad,
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
  Future<Usuario> actualizarPerfil(
      {String? nombre, String? telefono, Uint8List? fotoBytes});
}
