import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/hosteria_model.dart';

class HosteriaDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );

  Future<List<HosteriaModel>> getHosterias() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.hosterias)
          .where('activa', isEqualTo: true)
          .get();

      return querySnapshot.docs.map(HosteriaModel.fromFirestore).toList();
    } catch (e) {
      throw const FirestoreFailure('Error al obtener la lista de hosterías');
    }
  }

  Future<HosteriaModel> getHosteriaById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.hosterias)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const FirestoreFailure('Hostería no encontrada');
      }

      return HosteriaModel.fromFirestore(doc);
    } catch (e) {
      throw const FirestoreFailure(
        'Error al obtener el detalle de la hostería',
      );
    }
  }

  Future<List<HosteriaModel>> buscarHosterias(String query) async {
    try {
      // Búsqueda simple (Firestore no soporta full text search nativo,
      // esto asume prefijos o filtros exactos. Para un search real
      // se debería usar Algolia o un enfoque diferente, pero
      // lo simularemos obteniendo todas y filtrando localmente para este proyecto)
      final querySnapshot = await _firestore
          .collection(FirestorePaths.hosterias)
          .where('activa', isEqualTo: true)
          .get();

      final hosterias = querySnapshot.docs
          .map(HosteriaModel.fromFirestore)
          .toList();

      final searchLower = query.toLowerCase();
      return hosterias
          .where(
            (h) =>
                h.nombre.toLowerCase().contains(searchLower) ||
                h.descripcion.toLowerCase().contains(searchLower),
          )
          .toList();
    } catch (e) {
      throw const FirestoreFailure('Error al buscar hosterías');
    }
  }
}
