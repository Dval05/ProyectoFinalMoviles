import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pago.dart';

/// Modelo de datos: Pago (serialización Firestore)
class PagoModel extends Pago {
  const PagoModel({
    required super.id,
    required super.reservaId,
    required super.usuarioId,
    required super.monto,
    required super.metodo,
    required super.referencia, required super.fechaPago, super.estado,
    super.comprobanteUrl,
  });

  factory PagoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return PagoModel(
      id: doc.id,
      reservaId: data['reservaId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      monto: (data['monto'] as num?)?.toDouble() ?? 0.0,
      metodo: data['metodo'] ?? 'tarjeta',
      estado: data['estado'] ?? 'pendiente',
      referencia: data['referencia'] ?? '',
      fechaPago: (data['fechaPago'] as Timestamp?)?.toDate() ?? DateTime.now(),
      comprobanteUrl: data['comprobanteUrl'],
    );
  }

  factory PagoModel.fromEntity(Pago entity) {
    return PagoModel(
      id: entity.id,
      reservaId: entity.reservaId,
      usuarioId: entity.usuarioId,
      monto: entity.monto,
      metodo: entity.metodo,
      estado: entity.estado,
      referencia: entity.referencia,
      fechaPago: entity.fechaPago,
      comprobanteUrl: entity.comprobanteUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservaId': reservaId,
      'usuarioId': usuarioId,
      'monto': monto,
      'metodo': metodo,
      'estado': estado,
      'referencia': referencia,
      'fechaPago': Timestamp.fromDate(fechaPago),
      if (comprobanteUrl != null) 'comprobanteUrl': comprobanteUrl,
    };
  }
}
