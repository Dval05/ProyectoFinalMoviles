import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/error_handler.dart';
import '../../models/promocion_model.dart';

class PromocionDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );

  Future<List<PromocionModel>> getPromociones() async {
    try {
      final querySnapshot = await _firestore.collection('promociones').get();
      return querySnapshot.docs.map(PromocionModel.fromFirestore).toList();
    } catch (e) {
      throw ServerFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<PromocionModel> crearPromocion(PromocionModel promocion) async {
    try {
      final docRef = _firestore.collection('promociones').doc();
      final newPromocion = PromocionModel(
        id: docRef.id,
        titulo: promocion.titulo,
        descripcion: promocion.descripcion,
        descuentoPorcentaje: promocion.descuentoPorcentaje,
        fechaInicio: promocion.fechaInicio,
        fechaFin: promocion.fechaFin,
        hosteriaId: promocion.hosteriaId,
        habitacionId: promocion.habitacionId,
        activa: promocion.activa,
      );
      await docRef.set(newPromocion.toFirestore());
      return newPromocion;
    } catch (e) {
      throw ServerFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }

  Future<void> actualizarPromocion(PromocionModel promocion) async {
    try {
      await _firestore.collection('promociones').doc(promocion.id).update(promocion.toFirestore());
    } catch (e) {
      throw ServerFailure(ErrorHandler.getFriendlyMessage(e));
    }
  }
}
