import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/reserva_model.dart';

class ReservaDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );

  Future<ReservaModel> crearReserva(ReservaModel reserva) async {
    try {
      final docRef = await _firestore
          .collection(FirestorePaths.reservas)
          .add(reserva.toJson());

      final savedDoc = await docRef.get();
      return ReservaModel.fromFirestore(savedDoc);
    } catch (e) {
      throw const FirestoreFailure('Error al crear la reserva');
    }
  }

  Future<List<ReservaModel>> getTodasLasReservas() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map(ReservaModel.fromFirestore)
          .toList();
    } catch (e) {
      debugPrint(r'Error en getTodasLasReservas: $e');
      throw const FirestoreFailure('Error al obtener todas las reservas');
    }
  }

  Future<List<ReservaModel>> getReservasPorUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map(ReservaModel.fromFirestore)
          .toList();
    } catch (e) {
      debugPrint(r'Error en getReservasPorUsuario: $e');
      throw const FirestoreFailure('Error al obtener el historial de reservas');
    }
  }

  Future<List<ReservaModel>> getReservasPorHabitacion(String habitacionId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .where('habitacionId', isEqualTo: habitacionId)
          // We don't order by fechaCreacion here, we'll just get them all to check dates
          .get();

      return querySnapshot.docs
          .map(ReservaModel.fromFirestore)
          .toList();
    } catch (e) {
      debugPrint(r'Error en getReservasPorHabitacion: $e');
      throw const FirestoreFailure('Error al obtener las reservas de la habitación');
    }
  }

  Future<ReservaModel> getReservaById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.reservas)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const FirestoreFailure('Reserva no encontrada');
      }

      return ReservaModel.fromFirestore(doc);
    } catch (e) {
      throw const FirestoreFailure('Error al obtener detalle de reserva');
    }
  }

  Future<void> actualizarEstado(String reservaId, String nuevoEstado) async {
    try {
      await _firestore
          .collection(FirestorePaths.reservas)
          .doc(reservaId)
          .update({'estado': nuevoEstado});
    } catch (e) {
      throw const FirestoreFailure('Error al actualizar estado de la reserva');
    }
  }
}
