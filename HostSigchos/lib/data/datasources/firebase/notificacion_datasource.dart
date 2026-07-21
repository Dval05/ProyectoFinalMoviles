import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/entities/notificacion.dart';

class NotificacionDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );

  Stream<List<NotificacionApp>> getNotificacionesStream(String usuarioId) {
    return _firestore
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificacionApp(
          id: doc.id,
          usuarioId: data['usuarioId'] ?? '',
          titulo: data['titulo'] ?? '',
          mensaje: data['mensaje'] ?? '',
          fecha: (data['fecha'] as Timestamp).toDate(),
          leida: data['leida'] ?? false,
          tipo: data['tipo'] ?? 'sistema',
        );
      }).toList();
    });
  }

  Future<void> marcarLeida(String id) async {
    await _firestore.collection('notificaciones').doc(id).update({
      'leida': true,
    });
  }

  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('leida', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'leida': true});
    }

    await batch.commit();
  }

  Future<void> borrarTodas(String usuarioId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
