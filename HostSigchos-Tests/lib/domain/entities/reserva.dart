/// Entidad de dominio: Reserva de habitación
///
/// Estados posibles: pendiente, confirmada, cancelada, completada
class Reserva {
  const Reserva({
    required this.id,
    required this.usuarioId,
    required this.hosteriaId,
    required this.habitacionId,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numHuespedes,
    required this.precioTotal,
    required this.fechaCreacion,
    this.numHabitaciones = 1,
    this.estado = 'pendiente',
    this.notas,
    this.nombreHosteria,
    this.tipoHabitacion,
    this.esParaOtraPersona = false,
    this.nombreOtraPersona,
  });
  final String id;
  final String usuarioId;
  final String hosteriaId;
  final String habitacionId;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int numHuespedes;
  final int numHabitaciones;
  final double precioTotal;
  final String estado;
  final DateTime fechaCreacion;
  final String? notas;
  final String? nombreHosteria;
  final String? tipoHabitacion;
  final bool esParaOtraPersona;
  final String? nombreOtraPersona;

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
    int? numHabitaciones,
    double? precioTotal,
    String? estado,
    DateTime? fechaCreacion,
    String? notas,
    String? nombreHosteria,
    String? tipoHabitacion,
    bool? esParaOtraPersona,
    String? nombreOtraPersona,
  }) {
    return Reserva(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      hosteriaId: hosteriaId ?? this.hosteriaId,
      habitacionId: habitacionId ?? this.habitacionId,
      fechaCheckIn: fechaCheckIn ?? this.fechaCheckIn,
      fechaCheckOut: fechaCheckOut ?? this.fechaCheckOut,
      numHuespedes: numHuespedes ?? this.numHuespedes,
      numHabitaciones: numHabitaciones ?? this.numHabitaciones,
      precioTotal: precioTotal ?? this.precioTotal,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      notas: notas ?? this.notas,
      nombreHosteria: nombreHosteria ?? this.nombreHosteria,
      tipoHabitacion: tipoHabitacion ?? this.tipoHabitacion,
      esParaOtraPersona: esParaOtraPersona ?? this.esParaOtraPersona,
      nombreOtraPersona: nombreOtraPersona ?? this.nombreOtraPersona,
    );
  }
}
