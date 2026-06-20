import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../models/habitacion_model.dart';

import 'package:firebase_core/firebase_core.dart';

class HabitacionDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos');

  Future<List<HabitacionModel>> getHabitacionesPorHosteria(String hosteriaId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestorePaths.habitaciones)
          .where('hosteriaId', isEqualTo: hosteriaId)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitacionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw const FirestoreFailure('Error al obtener habitaciones de la hostería');
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
      String habitacionId, DateTime checkIn, DateTime checkOut) async {
    try {
      // 1. Verificar si la habitación existe y está activa
      final doc = await _firestore
          .collection(FirestorePaths.habitaciones)
          .doc(habitacionId)
          .get();

      if (!doc.exists || !(doc.data()?['disponible'] ?? false)) {
        return false;
      }

      // 2. Verificar cruce de fechas en reservas existentes
      // Para simplificar, buscamos reservas de esta habitación
      // que estén activas (pendiente o confirmada)
      final reservasSnapshot = await _firestore
          .collection(FirestorePaths.reservas)
          .where('habitacionId', isEqualTo: habitacionId)
          .where('estado', whereIn: ['pendiente', 'confirmada'])
          .get();

      for (var reservaDoc in reservasSnapshot.docs) {
        final rCheckIn = (reservaDoc.data()['fechaCheckIn'] as Timestamp).toDate();
        final rCheckOut = (reservaDoc.data()['fechaCheckOut'] as Timestamp).toDate();

        // Lógica de cruce de fechas:
        // Una reserva se cruza si el checkIn propuesto es ANTES del checkOut existente,
        // Y el checkOut propuesto es DESPUÉS del checkIn existente.
        if (checkIn.isBefore(rCheckOut) && checkOut.isAfter(rCheckIn)) {
          return false; // Hay choque, no disponible
        }
      }

      return true; // Disponible
    } catch (e) {
      throw const FirestoreFailure('Error al verificar disponibilidad');
    }
  }
}
