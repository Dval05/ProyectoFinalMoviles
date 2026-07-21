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
      final docRef = _firestore.collection(FirestorePaths.reservas).doc();
      final habitacionRef = _firestore.collection('habitaciones').doc(reserva.habitacionId);

      await _firestore.runTransaction((transaction) async {
        // 1. Leer el documento de la habitación para establecer el lock de escritura
        final habitacionDoc = await transaction.get(habitacionRef);
        if (!habitacionDoc.exists) {
          throw const FirestoreFailure('La habitación seleccionada no existe');
        }

        // 2. Verificar disponibilidad consultando reservas
        final querySnapshot = await _firestore
            .collection(FirestorePaths.reservas)
            .where('habitacionId', isEqualTo: reserva.habitacionId)
            .where('estado', isNotEqualTo: 'Cancelada')
            .get();

        for (final doc in querySnapshot.docs) {
          final res = ReservaModel.fromFirestore(doc);
          final overlap = reserva.fechaCheckIn.isBefore(res.fechaCheckOut) &&
                          reserva.fechaCheckOut.isAfter(res.fechaCheckIn);
          if (overlap) {
            throw const FirestoreFailure('La habitación ya no está disponible para estas fechas. Alguien acaba de reservarla.');
          }
        }

        // 3. Crear la reserva
        final reservaConId = ReservaModel.fromEntity(reserva.copyWith(id: docRef.id));
        transaction
          ..set(docRef, reservaConId.toJson())

        // 4. Actualizar la habitación para forzar el reintento si hay colisión (Race Condition)
          ..update(habitacionRef, {
            'ultimaReservaActiva': FieldValue.serverTimestamp(),
          });
      });

      final savedDoc = await docRef.get();
      return ReservaModel.fromFirestore(savedDoc);
    } catch (e) {
      if (e is FirestoreFailure) rethrow;
      if (e.toString().contains('permission-denied')) {
        throw const FirestoreFailure('Acceso denegado. No se pudo completar la reserva (posible error de permisos o servidor).');
      }
      throw const FirestoreFailure('Ocurrió un error inesperado al procesar la reserva. Por favor intenta nuevamente.');
    }
  }

  Future<List<ReservaModel>> getTodasLasReservas() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs.map(ReservaModel.fromFirestore).toList();
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

      return querySnapshot.docs.map(ReservaModel.fromFirestore).toList();
    } catch (e) {
      debugPrint(r'Error en getReservasPorUsuario: $e');
      throw const FirestoreFailure('Error al obtener el historial de reservas');
    }
  }

  Future<List<ReservaModel>> getReservasPorHabitacion(
    String habitacionId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .where('habitacionId', isEqualTo: habitacionId)
          // We don't order by fechaCreacion here, we'll just get them all to check dates
          .get();

      return querySnapshot.docs.map(ReservaModel.fromFirestore).toList();
    } catch (e) {
      debugPrint(r'Error en getReservasPorHabitacion: $e');
      throw const FirestoreFailure(
        'Error al obtener las reservas de la habitación',
      );
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
