// Import removed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/env.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/error_handler.dart';
import '../../models/usuario_model.dart';
import 'storage_datasource.dart';

class AuthDataSource {
  AuthDataSource(this._storageDataSource);
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final StorageDataSource _storageDataSource;
  bool _isGoogleSignInInitialized = false;

  Stream<UsuarioModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore
            .collection(FirestorePaths.usuarios)
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return UsuarioModel.fromFirestore(doc);
        }
      } catch (e) {
        debugPrint(r'Error obteniendo usuario en stream: $e');
      }
      return null;
    });
  }

  Future<UsuarioModel> loginConEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserFromFirestore(cred.user!.uid);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<UsuarioModel> registrarse({
    required String nombre,
    required String email,
    required String password,
    required String cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? fotoUrl;
      if (fotoBytes != null) {
        fotoUrl = await _storageDataSource.subirFotoPerfil(
          cred.user!.uid,
          fotoBytes,
        );
      }

      final nuevoUsuario = UsuarioModel(
        id: cred.user!.uid,
        nombre: nombre,
        email: email,
        cedula: cedula,
        fechaNacimiento: fechaNacimiento,
        telefono: telefono,
        ubicacion: ubicacion,
        fotoUrl: fotoUrl,
        fechaRegistro: DateTime.now(),
      );

      await _firestore
          .collection(FirestorePaths.usuarios)
          .doc(cred.user!.uid)
          .set(nuevoUsuario.toJson());

      return nuevoUsuario;
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<UsuarioModel> loginConGoogle() async {
    try {
      auth.User? user;


        // Inicializar Google Sign-In con el Web Client ID
        if (!_isGoogleSignInInitialized) {
          final webClientId = Env.googleWebClientId;
          debugPrint('[GoogleAuth] Inicializando con serverClientId: '
              '${webClientId.isNotEmpty ? '${webClientId.substring(0, 10)}...' : 'VACÍO'}');
          await _googleSignIn.initialize(
            serverClientId: webClientId,
          );
          _isGoogleSignInInitialized = true;
          debugPrint('[GoogleAuth] Inicialización completada');
        }

        // Autenticar con Google
        debugPrint('[GoogleAuth] Iniciando authenticate()...');
        final GoogleSignInAccount googleUser;
        try {
          googleUser = await _googleSignIn.authenticate();
        } catch (e) {
          debugPrint('[GoogleAuth] Error en authenticate(): $e');
          debugPrint('[GoogleAuth] Tipo de error: ${e.runtimeType}');
          rethrow;
        }
        debugPrint('[GoogleAuth] Autenticación exitosa: ${googleUser.email}');

        // Obtener tokens
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;
        debugPrint('[GoogleAuth] idToken presente: ${googleAuth.idToken != null}');

        final cred = auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential = await _firebaseAuth.signInWithCredential(cred);
        user = userCredential.user;
        debugPrint('[GoogleAuth] Firebase signIn exitoso: ${user?.uid}');
        debugPrint('[GoogleAuth] Firebase signIn exitoso: ${user?.uid}');

      if (user == null) throw const AuthFailure('Error al autenticar usuario');

      // Check if user exists in Firestore
      final doc = await _firestore
          .collection(FirestorePaths.usuarios)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        final nuevoUsuario = UsuarioModel(
          id: user.uid,
          nombre: user.displayName ?? 'Usuario de Google',
          email: user.email!,
          fotoUrl: user.photoURL,
          fechaRegistro: DateTime.now(),
        );
        await _firestore
            .collection(FirestorePaths.usuarios)
            .doc(user.uid)
            .set(nuevoUsuario.toJson());
        return nuevoUsuario;
      }

      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('[GoogleAuth] ERROR FINAL: $e');
      debugPrint('[GoogleAuth] Tipo: ${e.runtimeType}');
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _firebaseAuth.signOut();
      // Disparamos el cierre de sesión de Google sin esperar (fire-and-forget)
      // para evitar que bloquee la interfaz si la plataforma no lo soporta bien o tarda.
      _googleSignIn.signOut().catchError((_) => null);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<UsuarioModel> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.usuarios)
          .doc(uid)
          .get();
      if (!doc.exists) {
        throw const AuthFailure('Usuario no encontrado en base de datos');
      }
      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<UsuarioModel?> getUsuarioActual() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid);
    }
    return null;
  }

  Future<UsuarioModel> actualizarPerfil({
    required String uid,
    String? nombre,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    Uint8List? fotoBytes,
  }) async {
    try {
      final docRef = _firestore.collection(FirestorePaths.usuarios).doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw const AuthFailure('Usuario no encontrado');
      }

      String? nuevaFotoUrl;
      if (fotoBytes != null) {
        nuevaFotoUrl = await _storageDataSource.subirFotoPerfil(uid, fotoBytes);
      }

      final dataToUpdate = <String, dynamic>{};
      if (nombre != null) dataToUpdate['nombre'] = nombre;
      if (cedula != null) dataToUpdate['cedula'] = cedula;
      if (fechaNacimiento != null) {
        dataToUpdate['fechaNacimiento'] = Timestamp.fromDate(fechaNacimiento);
      }
      if (telefono != null) dataToUpdate['telefono'] = telefono;
      if (ubicacion != null) dataToUpdate['ubicacion'] = ubicacion;
      if (nuevaFotoUrl != null) dataToUpdate['fotoUrl'] = nuevaFotoUrl;

      if (dataToUpdate.isNotEmpty) {
        await docRef.update(dataToUpdate);
      }

      // Devolver el usuario actualizado
      final updatedDoc = await docRef.get();
      return UsuarioModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  // ==================== NUEVOS MÉTODOS ====================

  /// Vincular una contraseña a una cuenta de Google
  Future<void> vincularPasswordAGoogle({required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('No hay usuario autenticado');

      final email = user.email;
      if (email == null) throw const AuthFailure('El usuario no tiene email');

      final credential = auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  /// Enviar correo de verificación al email del usuario actual
  Future<void> enviarVerificacionEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('No hay usuario autenticado');
      await user.sendEmailVerification();
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  /// Enviar correo de recuperación de contraseña
  Future<void> enviarCorreoRecuperacionPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  /// Verificar si el email del usuario actual fue confirmado
  Future<bool> verificarEmailConfirmado() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Las cuentas vinculadas con Google ya tienen el email verificado
      final providers = user.providerData.map((p) => p.providerId).toList();
      if (providers.contains('google.com')) return true;

      await user.reload();
      // Obtener el usuario actualizado después del reload
      final updatedUser = _firebaseAuth.currentUser;
      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }



  /// Verificar si el usuario actual solo tiene proveedor Google (sin password)
  Future<bool> esUsuarioSoloGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    final providers = user.providerData.map((p) => p.providerId).toList();
    return providers.contains('google.com') && !providers.contains('password');
  }

  /// Eliminar cuenta (borrado lógico en Firestore y físico en Auth)
  Future<void> eliminarCuenta() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('No hay usuario autenticado');

      // 1. Borrado lógico en Firestore
      final docRef = _firestore.collection(FirestorePaths.usuarios).doc(user.uid);
      await docRef.update({
        'nombre': 'Usuario Eliminado',
        'email': 'eliminado_${user.uid}@hostsigchos.com',
        'telefono': FieldValue.delete(),
        'cedula': FieldValue.delete(),
        'edad': FieldValue.delete(),
        'fechaNacimiento': FieldValue.delete(),
        'fotoUrl': FieldValue.delete(),
        'ubicacion': FieldValue.delete(),
        'estado': 'eliminado',
      });

      // 2. Eliminar de Firebase Auth
      await user.delete();

      // 3. Cerrar sesión en Google Sign In por si acaso
      _googleSignIn.signOut().catchError((_) => null);
    } catch (e) {
      if (e is auth.FirebaseAuthException && e.code == 'requires-recent-login') {
        throw const AuthFailure('Por seguridad, cierra sesión, vuelve a ingresar e intenta nuevamente.');
      }
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }
}
