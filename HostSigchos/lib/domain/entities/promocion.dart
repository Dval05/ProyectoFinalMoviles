class Promocion {
  const Promocion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.descuentoPorcentaje,
    required this.fechaInicio,
    required this.fechaFin,
    this.hosteriaId,
    this.habitacionId,
    this.activa = true,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final double descuentoPorcentaje;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? hosteriaId;
  final String? habitacionId;
  final bool activa;

  Promocion copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    double? descuentoPorcentaje,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? hosteriaId,
    String? habitacionId,
    bool? activa,
  }) {
    return Promocion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      descuentoPorcentaje: descuentoPorcentaje ?? this.descuentoPorcentaje,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      hosteriaId: hosteriaId ?? this.hosteriaId,
      habitacionId: habitacionId ?? this.habitacionId,
      activa: activa ?? this.activa,
    );
  }
}
