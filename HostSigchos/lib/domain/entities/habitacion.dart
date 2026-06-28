/// Entidad de dominio: Habitación de una hostería
class Habitacion {
  const Habitacion({
    required this.id,
    required this.hosteriaId,
    required this.tipo,
    required this.descripcion,
    required this.capacidad,
    required this.precioPorNoche,
    this.imagenes = const [],
    this.amenidades = const [],
    this.disponible = true,
    this.cantidadTotal = 10,
  });
  final String id;
  final String hosteriaId;
  final String tipo;
  final String descripcion;
  final int capacidad;
  final double precioPorNoche;
  final List<String> imagenes;
  final List<String> amenidades;
  final bool disponible;
  final int cantidadTotal;

  Habitacion copyWith({
    String? id,
    String? hosteriaId,
    String? tipo,
    String? descripcion,
    int? capacidad,
    double? precioPorNoche,
    List<String>? imagenes,
    List<String>? amenidades,
    bool? disponible,
    int? cantidadTotal,
  }) {
    return Habitacion(
      id: id ?? this.id,
      hosteriaId: hosteriaId ?? this.hosteriaId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      capacidad: capacidad ?? this.capacidad,
      precioPorNoche: precioPorNoche ?? this.precioPorNoche,
      imagenes: imagenes ?? this.imagenes,
      amenidades: amenidades ?? this.amenidades,
      disponible: disponible ?? this.disponible,
      cantidadTotal: cantidadTotal ?? this.cantidadTotal,
    );
  }
}
