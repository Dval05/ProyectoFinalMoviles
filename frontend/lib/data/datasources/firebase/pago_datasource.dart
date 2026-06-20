import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/pago_model.dart';

import 'package:firebase_core/firebase_core.dart';

class PagoDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos');

  Future<PagoModel> procesarPago(PagoModel pago) async {
    try {
      // Guarda el registro del pago en Firestore
      final docRef = await _firestore
          .collection(FirestorePaths.pagos)
          .add(pago.toJson());

      // Retorna el modelo con el ID autogenerado
      final savedDoc = await docRef.get();
      return PagoModel.fromFirestore(savedDoc);
    } catch (e) {
      throw const FirestoreFailure('Error al registrar el pago en la base de datos');
    }
  }

  Future<List<PagoModel>> getPagosPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.pagos)
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fechaPago', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PagoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw const FirestoreFailure('Error al obtener el historial de pagos');
    }
  }

  Future<PagoModel?> getPagoPorReserva(String reservaId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.pagos)
          .where('reservaId', isEqualTo: reservaId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return PagoModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw const FirestoreFailure('Error al obtener el pago de la reserva');
    }
  }
}
