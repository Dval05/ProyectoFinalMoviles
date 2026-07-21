import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../models/hosteria_model.dart';
import '../../models/resena_model.dart';

class ResenaDataSource {
  const ResenaDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<ResenaModel>> getResenasPorHosteria(String hosteriaId) {
    return _firestore
        .collection(FirestorePaths.resenas)
        .where('hosteriaId', isEqualTo: hosteriaId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(ResenaModel.fromFirestore).toList();
    });
  }

  Future<void> agregarResena(ResenaModel resena) async {
    try {
      final hosteriaRef = _firestore.collection(FirestorePaths.hosterias).doc(resena.hosteriaId);
      final resenaRef = _firestore.collection(FirestorePaths.resenas).doc(); // Autogenerado

      await _firestore.runTransaction((transaction) async {
        final hosteriaSnapshot = await transaction.get(hosteriaRef);
        
        if (!hosteriaSnapshot.exists) {
          throw Exception('Hosteria no encontrada');
        }

        final hosteria = HosteriaModel.fromFirestore(hosteriaSnapshot);
        
        final double currentRating = hosteria.rating;
        final int currentTotal = hosteria.totalResenas;
        
        // Calcular el nuevo promedio
        final int newTotal = currentTotal + 1;
        final double newRating = ((currentRating * currentTotal) + resena.rating) / newTotal;

        // Actualizar hosteria
        transaction.update(hosteriaRef, {
          'rating': newRating,
          'totalResenas': newTotal,
        });

        // Crear reseña
        final resenaToSave = ResenaModel(
          id: resenaRef.id,
          hosteriaId: resena.hosteriaId,
          usuarioId: resena.usuarioId,
          nombreUsuario: resena.nombreUsuario,
          comentario: resena.comentario,
          rating: resena.rating,
          fecha: resena.fecha,
        );
        transaction.set(resenaRef, resenaToSave.toFirestore());
      });
    } catch (e) {
      throw Exception('Error al guardar la reseña');
    }
  }
}
