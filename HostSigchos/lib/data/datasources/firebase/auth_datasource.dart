// Import removed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    String rol = 'usuario',
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
        rol: rol,
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

      if (kIsWeb) {
        final googleProvider = auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        user = userCredential.user;
      } else {
        if (!_isGoogleSignInInitialized) {
          await _googleSignIn.initialize();
          _isGoogleSignInInitialized = true;
        }
        final GoogleSignInAccount googleUser = await _googleSignIn
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final cred = auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential = await _firebaseAuth.signInWithCredential(cred);
        user = userCredential.user;
      }

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
          rol: 'usuario',
        );
        await _firestore
            .collection(FirestorePaths.usuarios)
            .doc(user.uid)
            .set(nuevoUsuario.toJson());
        return nuevoUsuario;
      }

      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
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

  /// Verificar si el email del usuario actual fue confirmado
  Future<bool> verificarEmailConfirmado() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      await user.reload();
      // Obtener el usuario actualizado después del reload
      final updatedUser = _firebaseAuth.currentUser;
      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  /// Enviar código SMS al teléfono
  Future<void> enviarCodigoTelefono({
    required String telefono,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: telefono,
        verificationCompleted: (credential) async {
          // Auto-verificación en Android (lectura automática de SMS)
          try {
            final user = _firebaseAuth.currentUser;
            if (user != null) {
              await user.linkWithCredential(credential);
            }
          } catch (e) {
            debugPrint('Error en auto-verificación: $e');
          }
        },
        verificationFailed: (e) {
          onError(e.message ?? 'Error al enviar código SMS');
        },
        codeSent: (verificationId, resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Timeout de auto-lectura del SMS
          debugPrint('Timeout de auto-lectura SMS: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw AuthFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  /// Verificar código SMS ingresado por el usuario
  Future<bool> verificarCodigoTelefono({
    required String verificationId,
    required String code,
  }) async {
    try {
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Vincular teléfono al usuario existente
        await user.linkWithCredential(credential);
        return true;
      }
      return false;
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
}
