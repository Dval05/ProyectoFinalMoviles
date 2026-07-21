import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';

class StorageDataSource {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String> subirFotoPerfil(String userId, Uint8List fotoBytes) async {
    try {
      debugPrint('--- INICIANDO SUBIDA DE FOTO ---');
      debugPrint('Bucket configurado en la app: ${_storage.app.options.storageBucket}');
      debugPrint('UserID: $userId');
      debugPrint('Tamaño de imagen (bytes): ${fotoBytes.length}');

      final ref = _storage.ref().child('perfiles').child('$userId.jpg');
      debugPrint('Ruta destino: ${ref.fullPath}');
      debugPrint('Bucket destino: ${ref.bucket}');

      debugPrint('Ejecutando putData...');
      final uploadTask = await ref.putData(
        fotoBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      debugPrint('putData finalizado exitosamente.');
      debugPrint('Bytes transferidos: ${uploadTask.bytesTransferred} / ${uploadTask.totalBytes}');
      debugPrint('Estado final: ${uploadTask.state}');

      debugPrint('Obteniendo URL de descarga...');
      final url = await uploadTask.ref.getDownloadURL();
      debugPrint('URL obtenida: $url');
      debugPrint('--- SUBIDA DE FOTO COMPLETADA ---');
      return url;
    } on FirebaseException catch (e) {
      debugPrint('--- ERROR FIREBASE STORAGE ---');
      debugPrint('Código: ${e.code}');
      debugPrint('Mensaje: ${e.message}');
      debugPrint('Plugin: ${e.plugin}');
      throw StorageFailure('Error al subir la foto de perfil: ${e.message}');
    } catch (e) {
      debugPrint('--- ERROR GENERAL STORAGE ---');
      debugPrint(e.toString());
      throw Exception('Error inesperado al subir la imagen');
    }
  }
}
