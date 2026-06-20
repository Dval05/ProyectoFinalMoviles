import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habitacion.dart';

/// Modelo de datos: Habitación (serialización Firestore)
class HabitacionModel extends Habitacion {
  const HabitacionModel({
    required super.id,
    required super.hosteriaId,
    required super.tipo,
    required super.descripcion,
    required super.capacidad,
    required super.precioPorNoche,
    super.imagenes,
    super.amenidades,
    super.disponible,
  });

  factory HabitacionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitacionModel(
      id: doc.id,
      hosteriaId: data['hosteriaId'] ?? '',
      tipo: data['tipo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      capacidad: (data['capacidad'] as num?)?.toInt() ?? 1,
      precioPorNoche: (data['precioPorNoche'] as num?)?.toDouble() ?? 0.0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      amenidades: List<String>.from(data['amenidades'] ?? []),
      disponible: data['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hosteriaId': hosteriaId,
      'tipo': tipo,
      'descripcion': descripcion,
      'capacidad': capacidad,
      'precioPorNoche': precioPorNoche,
      'imagenes': imagenes,
      'amenidades': amenidades,
      'disponible': disponible,
    };
  }
}
