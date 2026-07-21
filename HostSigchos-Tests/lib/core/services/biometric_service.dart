import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  factory BiometricService() => _instance;
  BiometricService._internal();
  static final BiometricService _instance = BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyEmail = 'biometric_email';
  static const String _keyPassword = 'biometric_password';

  /// Verifica si el dispositivo soporta biometría y está configurada
  Future<bool> isBiometricAvailable() async {

    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error comprobando biometría: $e');
      return false;
    }
  }

  /// Inicia el diálogo de autenticación biométrica
  Future<bool> authenticate({
    String reason = 'Verifica tu identidad para iniciar sesión',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticación requerida',
            cancelButton: 'Cancelar',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
          ),
        ],
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
      return false;
    }
  }

  /// Guarda las credenciales de manera segura (si el usuario aceptó usar biometría)
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Obtiene las credenciales guardadas si existen
  Future<Map<String, String>?> getCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Borra las credenciales guardadas (útil si el usuario desactiva la opción o cambia de cuenta)
  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
  }

  /// Verifica si hay credenciales guardadas para mostrar o no el botón
  Future<bool> hasSavedCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    return email != null && email.isNotEmpty;
  }
}
