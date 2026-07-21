import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/services/biometric_service.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/actualizar_perfil_usecase.dart';
import '../../domain/usecases/auth/eliminar_cuenta_usecase.dart';
import '../../domain/usecases/auth/google_signin_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/recuperar_password_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/verificar_email_usecase.dart';
import '../../domain/usecases/auth/vincular_password_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInUseCase,
    required this.logoutUseCase,
    required this.actualizarPerfilUseCase,
    required this.vincularPasswordUseCase,
    required this.verificarEmailUseCase,
    required this.recuperarPasswordUseCase,
    required this.eliminarCuentaUseCase,
    required this.authRepository,
  }) {
    _checkBiometricStatus();
  }
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final LogoutUseCase logoutUseCase;
  final ActualizarPerfilUseCase actualizarPerfilUseCase;
  final VincularPasswordUseCase vincularPasswordUseCase;
  final VerificarEmailUseCase verificarEmailUseCase;
  final RecuperarPasswordUseCase recuperarPasswordUseCase;
  final EliminarCuentaUseCase eliminarCuentaUseCase;
  final AuthRepository authRepository;

  Usuario? _usuarioActual;
  bool _isLoading = false;
  String? _errorMessage;
  bool _keepSession = true;

  // Estado de verificación
  bool _isEmailVerified = false;
  bool _isUsuarioSoloGoogle = false;

  // Biometría
  bool _isBiometricAvailable = false;
  bool _hasSavedCredentials = false;

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmailVerified => _isEmailVerified;
  bool get isUsuarioSoloGoogle => _isUsuarioSoloGoogle;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get hasSavedCredentials => _hasSavedCredentials;
  bool get keepSession => _keepSession;

  void setKeepSession({required bool value}) {
    _keepSession = value;
    notifyListeners();
  }

  Future<void> _checkBiometricStatus() async {
    final service = BiometricService();
    _isBiometricAvailable = await service.isBiometricAvailable();
    _hasSavedCredentials = await service.hasSavedCredentials();
    notifyListeners();
  }

  Future<void> checkCurrentSession() async {
    _setLoading(true);
    try {
      _usuarioActual = await authRepository.getUsuarioActual();
      notifyListeners();
    } catch (e) {
      debugPrint('Error comprobando sesion actual: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setUsuarioActual(Usuario? usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _usuarioActual = await loginUseCase(email, password);

      // Verificar email (no bloquea el login, solo registra el estado)
      if (!_usuarioActual!.email.endsWith('@hostsigchos.com')) {
         final isVerified = await authRepository.verificarEmailConfirmado();
         _isEmailVerified = isVerified;
         if (!isVerified) {
            debugPrint('[Auth] Email no verificado para: ${_usuarioActual!.email}');
            // No bloqueamos el login - el usuario puede usar la app
            // pero se le recordará verificar su email
         }
      } else {
        _isEmailVerified = true;
      }

      if (_isBiometricAvailable) {
        await BiometricService().saveCredentials(email, password);
        _hasSavedCredentials = true;
      }

      // Handle keep session
      const storage = FlutterSecureStorage();
      if (!_keepSession) {
        await storage.write(key: 'keep_session', value: 'false');
      } else {
        await storage.delete(key: 'keep_session');
      }

      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    _setLoading(true);
    try {
      _usuarioActual = await registerUseCase(
        nombre: nombre,
        email: email,
        password: password,
        cedula: cedula,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        ubicacion: ubicacion,
        fotoBytes: fotoBytes,
      );
      
      // Enviar correo de verificación automáticamente
      try {
        await verificarEmailUseCase.enviar();
      } catch (e) {
        debugPrint('Error enviando correo de verificación inicial: $e');
      }
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginConGoogle() async {
    _setLoading(true);
    try {
      _usuarioActual = await googleSignInUseCase();
      _errorMessage = null;
      // Verificar si es usuario solo de Google
      await _checkIfGoogleOnly();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await logoutUseCase();
      _usuarioActual = null;
      _isEmailVerified = false;
      _isUsuarioSoloGoogle = false;
      // No borramos las credenciales biométricas aquí, así el usuario puede volver a entrar
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarPerfil({
    required String uid,
    String? nombre,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    _setLoading(true);
    try {
      _usuarioActual = await actualizarPerfilUseCase(
        uid: uid,
        nombre: nombre,
        cedula: cedula,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        ubicacion: ubicacion,
        fotoBytes: fotoBytes,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== NUEVOS MÉTODOS ====================

  /// Vincular contraseña a cuenta de Google
  Future<bool> vincularPassword(String password) async {
    _setLoading(true);
    try {
      await vincularPasswordUseCase(password);
      _isUsuarioSoloGoogle = false;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar si el usuario actual es solo Google (sin password)
  Future<void> _checkIfGoogleOnly() async {
    try {
      _isUsuarioSoloGoogle = await vincularPasswordUseCase
          .esUsuarioSoloGoogle();
    } catch (_) {
      _isUsuarioSoloGoogle = false;
    }
  }

  /// Enviar correo de recuperación de contraseña
  Future<bool> recuperarPassword(String email) async {
    _setLoading(true);
    try {
      await recuperarPasswordUseCase(email);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar correo de verificación
  Future<bool> enviarVerificacionEmail() async {
    _setLoading(true);
    try {
      await verificarEmailUseCase.enviar();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Comprobar si el email fue verificado
  Future<bool> verificarEmail() async {
    _setLoading(true);
    try {
      _isEmailVerified = await verificarEmailUseCase.verificar();
      _errorMessage = null;
      notifyListeners();
      return _isEmailVerified;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }



  /// Eliminar cuenta de usuario
  Future<bool> eliminarCuenta() async {
    _setLoading(true);
    try {
      await eliminarCuentaUseCase();
      _usuarioActual = null;
      _isEmailVerified = false;
      _isUsuarioSoloGoogle = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== BIOMETRÍA ====================

  Future<bool> loginConBiometria() async {
    _setLoading(true);
    try {
      final service = BiometricService();
      final authenticated = await service.authenticate();

      if (!authenticated) {
        _setLoading(false);
        return false;
      }

      final credentials = await service.getCredentials();
      if (credentials == null) {
        _errorMessage =
            'No hay credenciales guardadas. Inicia sesión normalmente.';
        _setLoading(false);
        return false;
      }

      final email = credentials['email']!;
      final password = credentials['password']!;

      _usuarioActual = await loginUseCase(email, password);

      // Guardar credenciales para biometría si está disponible
      if (_isBiometricAvailable) {
        await BiometricService().saveCredentials(email, password);
        _hasSavedCredentials = true;
      }

      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
        _errorMessage = null;
      } else {
        _errorMessage = ErrorHandler.getFriendlyMessage(e);
      }
      _setLoading(false);
      return false;
    }
  }
}
