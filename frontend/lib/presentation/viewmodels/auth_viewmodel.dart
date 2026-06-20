import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/google_signin_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final LogoutUseCase _logoutUseCase;

  Usuario? _usuarioActual;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._googleSignInUseCase,
    required this._logoutUseCase,
  });

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setUsuarioActual(Usuario? usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _usuarioActual = await _loginUseCase(email, password);
      _errorMessage = null;
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
    int? edad,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    _setLoading(true);
    try {
      _usuarioActual = await _registerUseCase(
        nombre: nombre,
        email: email,
        password: password,
        cedula: cedula,
        edad: edad,
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

  Future<bool> loginConGoogle() async {
    _setLoading(true);
    try {
      _usuarioActual = await _googleSignInUseCase();
      _errorMessage = null;
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
      await _logoutUseCase();
      _usuarioActual = null;
    } catch (e) {
      _errorMessage = e.toString();
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
}
