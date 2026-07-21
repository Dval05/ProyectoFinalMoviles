import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/habitacion_model.dart';

class HabitacionDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'hostsigchos',
  );

  Future<List<HabitacionModel>> getHabitacionesPorHosteria(
    String hosteriaId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.habitaciones)
          .where('hosteriaId', isEqualTo: hosteriaId)
          .get();

      return querySnapshot.docs.map(HabitacionModel.fromFirestore).toList();
    } catch (e) {
      throw const FirestoreFailure(
        'Error al obtener habitaciones de la hostería',
      );
    }
  }

  Future<List<HabitacionModel>> getTodasLasHabitaciones() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.habitaciones)
          .get();

      return querySnapshot.docs.map(HabitacionModel.fromFirestore).toList();
    } catch (e) {
      throw const FirestoreFailure(
        'Error al obtener todas las habitaciones',
      );
    }
  }

  Future<HabitacionModel> getHabitacionById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.habitaciones)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw const FirestoreFailure('Habitación no encontrada');
      }

      return HabitacionModel.fromFirestore(doc);
    } catch (e) {
      throw const FirestoreFailure('Error al obtener la habitación');
    }
  }

  Future<bool> verificarDisponibilidad(
    String habitacionId,
    DateTime checkIn,
    DateTime checkOut,
    int cantidadSolicitada,
  ) async {
    try {
      // 1. Verificar si la habitación existe y está activa
      final doc = await _firestore
          .collection(FirestorePaths.habitaciones)
          .doc(habitacionId)
          .get();

      if (!doc.exists || !(doc.data()?['disponible'] ?? false)) {
        return false;
      }

      final cantidadTotal =
          (doc.data()?['cantidadTotal'] as num?)?.toInt() ?? 10;

      // 2. Verificar cruce de fechas en reservas existentes
      final reservasSnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .where('habitacionId', isEqualTo: habitacionId)
          .where('estado', whereIn: ['pendiente', 'confirmada'])
          .get();

      int habitacionesOcupadas = 0;

      for (final reservaDoc in reservasSnapshot.docs) {
        final rCheckIn = (reservaDoc.data()['fechaCheckIn'] as Timestamp)
            .toDate();
        final rCheckOut = (reservaDoc.data()['fechaCheckOut'] as Timestamp)
            .toDate();
        final numHabitaciones =
            (reservaDoc.data()['numHabitaciones'] as num?)?.toInt() ?? 1;

        if (checkIn.isBefore(rCheckOut) && checkOut.isAfter(rCheckIn)) {
          habitacionesOcupadas += numHabitaciones;
        }
      }

      return (cantidadTotal - habitacionesOcupadas) >= cantidadSolicitada;
    } catch (e) {
      throw const FirestoreFailure('Error al verificar disponibilidad');
    }
  }
}
