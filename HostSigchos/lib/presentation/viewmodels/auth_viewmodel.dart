import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/services/biometric_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/actualizar_perfil_usecase.dart';
import '../../domain/usecases/auth/google_signin_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/verificar_email_usecase.dart';
import '../../domain/usecases/auth/verificar_telefono_usecase.dart';
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
    required this.verificarTelefonoUseCase,
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
  final VerificarTelefonoUseCase verificarTelefonoUseCase;
  final AuthRepository authRepository;

  Usuario? _usuarioActual;
  bool _isLoading = false;
  String? _errorMessage;

  // Estado de verificación
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  String? _verificationId;
  bool _isUsuarioSoloGoogle = false;

  // Biometría
  bool _isBiometricAvailable = false;
  bool _hasSavedCredentials = false;

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmailVerified => _isEmailVerified;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get verificationId => _verificationId;
  bool get isUsuarioSoloGoogle => _isUsuarioSoloGoogle;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get hasSavedCredentials => _hasSavedCredentials;

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

      if (_isBiometricAvailable) {
        await BiometricService().saveCredentials(email, password);
        _hasSavedCredentials = true;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
    String rol = 'usuario',
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
        rol: rol,
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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
      _isPhoneVerified = false;
      _isUsuarioSoloGoogle = false;
      // No borramos las credenciales biométricas aquí, así el usuario puede volver a entrar
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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

  /// Enviar correo de verificación
  Future<bool> enviarVerificacionEmail() async {
    _setLoading(true);
    try {
      await verificarEmailUseCase.enviar();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar código SMS al teléfono
  Future<bool> enviarCodigoTelefono(String telefono) async {
    _setLoading(true);
    try {
      await verificarTelefonoUseCase.enviarCodigo(
        telefono: telefono,
        onCodeSent: (verificationId) {
          _verificationId = verificationId;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error;
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar código SMS ingresado
  Future<bool> verificarCodigoTelefono(String code) async {
    if (_verificationId == null) {
      _errorMessage = 'No se ha enviado un código de verificación';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    try {
      _isPhoneVerified = await verificarTelefonoUseCase.verificarCodigo(
        verificationId: _verificationId!,
        code: code,
      );
      _errorMessage = null;
      notifyListeners();
      return _isPhoneVerified;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
