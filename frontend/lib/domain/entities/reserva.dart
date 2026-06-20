/// Entidad de dominio: Reserva de habitación
///
/// Estados posibles: pendiente, confirmada, cancelada, completada
class Reserva {
  final String id;
  final String usuarioId;
  final String hosteriaId;
  final String habitacionId;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int numHuespedes;
  final double precioTotal;
  final String estado;
  final DateTime fechaCreacion;
  final String? notas;
  final String? nombreHosteria;
  final String? tipoHabitacion;

  const Reserva({
    required this.id,
    required this.usuarioId,
    required this.hosteriaId,
    required this.habitacionId,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numHuespedes,
    required this.precioTotal,
    this.estado = 'pendiente',
    required this.fechaCreacion,
    this.notas,
    this.nombreHosteria,
    this.tipoHabitacion,
  });

  int get noches => fechaCheckOut.difference(fechaCheckIn).inDays;
  bool get esCancelable => estado == 'pendiente' || estado == 'confirmada';
  bool get estaActiva => estado == 'pendiente' || estado == 'confirmada';

  Reserva copyWith({
    String? id,
    String? usuarioId,
    String? hosteriaId,
    String? habitacionId,
    DateTime? fechaCheckIn,
    DateTime? fechaCheckOut,
    int? numHuespedes,
    double? precioTotal,
    String? estado,
    DateTime? fechaCreacion,
    String? notas,
    String? nombreHosteria,
    String? tipoHabitacion,
  }) {
    return Reserva(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      hosteriaId: hosteriaId ?? this.hosteriaId,
      habitacionId: habitacionId ?? this.habitacionId,
      fechaCheckIn: fechaCheckIn ?? this.fechaCheckIn,
      fechaCheckOut: fechaCheckOut ?? this.fechaCheckOut,
      numHuespedes: numHuespedes ?? this.numHuespedes,
      precioTotal: precioTotal ?? this.precioTotal,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      notas: notas ?? this.notas,
      nombreHosteria: nombreHosteria ?? this.nombreHosteria,
      tipoHabitacion: tipoHabitacion ?? this.tipoHabitacion,
    );
  }
}
