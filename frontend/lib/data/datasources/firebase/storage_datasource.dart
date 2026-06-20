import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/errors/failures.dart';

class StorageDataSource {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String> subirFotoPerfil(String userId, Uint8List fotoBytes) async {
    try {
      final ref = _storage.ref().child('perfiles').child('$userId.jpg');
      final uploadTask = await ref.putData(
        fotoBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw StorageFailure('Error al subir la foto de perfil: $e');
    }
  }
}
