import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/promocion.dart';

class PromocionModel extends Promocion {
  const PromocionModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.descuentoPorcentaje,
    required super.fechaInicio,
    required super.fechaFin,
    super.hosteriaId,
    super.habitacionId,
    super.activa = true,
  });

  factory PromocionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return PromocionModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      descuentoPorcentaje: (data['descuentoPorcentaje'] ?? 0.0).toDouble(),
      fechaInicio:
          (data['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFin:
          (data['fechaFin'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      hosteriaId: data['hosteriaId'],
      habitacionId: data['habitacionId'],
      activa: data['activa'] ?? true,
    );
  }

  factory PromocionModel.fromEntity(Promocion promocion) {
    return PromocionModel(
      id: promocion.id,
      titulo: promocion.titulo,
      descripcion: promocion.descripcion,
      descuentoPorcentaje: promocion.descuentoPorcentaje,
      fechaInicio: promocion.fechaInicio,
      fechaFin: promocion.fechaFin,
      hosteriaId: promocion.hosteriaId,
      habitacionId: promocion.habitacionId,
      activa: promocion.activa,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'descuentoPorcentaje': descuentoPorcentaje,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'hosteriaId': hosteriaId,
      'habitacionId': habitacionId,
      'activa': activa,
    };
  }
}
