import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reserva.dart';

/// Modelo de datos: Reserva (serialización Firestore)
class ReservaModel extends Reserva {
  const ReservaModel({
    required super.id,
    required super.usuarioId,
    required super.hosteriaId,
    required super.habitacionId,
    required super.fechaCheckIn,
    required super.fechaCheckOut,
    required super.numHuespedes,
    required super.precioTotal,
    required super.fechaCreacion,
    super.numHabitaciones = 1,
    super.estado,
    super.notas,
    super.nombreHosteria,
    super.tipoHabitacion,
    super.esParaOtraPersona = false,
    super.nombreOtraPersona,
  });

  factory ReservaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ReservaModel(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      hosteriaId: data['hosteriaId'] ?? '',
      habitacionId: data['habitacionId'] ?? '',
      fechaCheckIn: (data['fechaCheckIn'] as Timestamp).toDate(),
      fechaCheckOut: (data['fechaCheckOut'] as Timestamp).toDate(),
      numHuespedes: (data['numHuespedes'] as num?)?.toInt() ?? 1,
      numHabitaciones: (data['numHabitaciones'] as num?)?.toInt() ?? 1,
      precioTotal: (data['precioTotal'] as num?)?.toDouble() ?? 0.0,
      estado: data['estado'] ?? 'pendiente',
      fechaCreacion:
          (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notas: data['notas'],
      nombreHosteria: data['nombreHosteria'],
      tipoHabitacion: data['tipoHabitacion'],
      esParaOtraPersona: data['esParaOtraPersona'] ?? false,
      nombreOtraPersona: data['nombreOtraPersona'],
    );
  }

  factory ReservaModel.fromEntity(Reserva entity) {
    return ReservaModel(
      id: entity.id,
      usuarioId: entity.usuarioId,
      hosteriaId: entity.hosteriaId,
      habitacionId: entity.habitacionId,
      fechaCheckIn: entity.fechaCheckIn,
      fechaCheckOut: entity.fechaCheckOut,
      numHuespedes: entity.numHuespedes,
      numHabitaciones: entity.numHabitaciones,
      precioTotal: entity.precioTotal,
      estado: entity.estado,
      fechaCreacion: entity.fechaCreacion,
      notas: entity.notas,
      nombreHosteria: entity.nombreHosteria,
      tipoHabitacion: entity.tipoHabitacion,
      esParaOtraPersona: entity.esParaOtraPersona,
      nombreOtraPersona: entity.nombreOtraPersona,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'hosteriaId': hosteriaId,
      'habitacionId': habitacionId,
      'fechaCheckIn': Timestamp.fromDate(fechaCheckIn),
      'fechaCheckOut': Timestamp.fromDate(fechaCheckOut),
      'numHuespedes': numHuespedes,
      'numHabitaciones': numHabitaciones,
      'precioTotal': precioTotal,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'notas': notas,
      'nombreHosteria': nombreHosteria,
      'tipoHabitacion': tipoHabitacion,
      'esParaOtraPersona': esParaOtraPersona,
      'nombreOtraPersona': nombreOtraPersona,
    };
  }
}
