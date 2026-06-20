// Import removed
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/usuario_model.dart';
import 'storage_datasource.dart';

class AuthDataSource {
  auth.FirebaseAuth get _firebaseAuth => auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos');
  late final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StorageDataSource _storageDataSource;

  AuthDataSource(this._storageDataSource);

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
        debugPrint('Error obteniendo usuario en stream: \$e');
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
    } on auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error de autenticación');
    } catch (e) {
      throw AuthFailure('Error desconocido al iniciar sesión');
    }
  }

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
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? fotoUrl;
      if (fotoBytes != null) {
        fotoUrl = await _storageDataSource.subirFotoPerfil(cred.user!.uid, fotoBytes);
      }

      final nuevoUsuario = UsuarioModel(
        id: cred.user!.uid,
        nombre: nombre,
        email: email,
        cedula: cedula,
        edad: edad,
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
    } on auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Error al registrar usuario');
    } catch (e) {
      throw AuthFailure('Error desconocido al registrarse');
    }
  }

  Future<UsuarioModel> loginConGoogle() async {
    try {
      auth.User? user;

      if (kIsWeb) {
        final googleProvider = auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        user = userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw const AuthFailure('Inicio de sesión cancelado');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final cred = auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
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
        );
        await _firestore
            .collection(FirestorePaths.usuarios)
            .doc(user.uid)
            .set(nuevoUsuario.toJson());
        return nuevoUsuario;
      }

      return UsuarioModel.fromFirestore(doc);
    } catch (e) {
      throw AuthFailure('Error al iniciar sesión con Google: $e');
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthFailure('Error al cerrar sesión');
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
      throw const FirestoreFailure('Error al obtener datos del usuario');
    }
  }

  Future<UsuarioModel?> getUsuarioActual() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await _getUserFromFirestore(user.uid);
    }
    return null;
  }
}
