import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../data/datasources/mock/mock_hosteria_datasource.dart';
import '../../data/datasources/mock/mock_habitacion_datasource.dart';

class DatabaseSeeder {
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos');
    final hosterias = MockHosteriaDataSource().mockHosterias;
    final habitaciones = MockHabitacionDataSource().mockHabitaciones;

    final batch = firestore.batch();

    // Seed Hosterias
    for (final hosteria in hosterias) {
      final docRef = firestore.collection('hosterias').doc(hosteria.id);
      batch.set(docRef, hosteria.toJson());
    }

    // Seed Habitaciones
    for (final habitacion in habitaciones) {
      final docRef = firestore.collection('habitaciones').doc(habitacion.id);
      batch.set(docRef, habitacion.toJson());
    }

    await batch.commit();
  }
}
