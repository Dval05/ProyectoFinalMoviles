/// Entidad de dominio: Hostería del cantón Sigchos
class Hosteria {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final double latitud;
  final double longitud;
  final String telefono;
  final String? email;
  final String? sitioWeb;
  final double rating;
  final List<String> imagenes;
  final List<String> servicios;
  final bool activa;

  const Hosteria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.telefono,
    this.email,
    this.sitioWeb,
    this.rating = 0.0,
    this.imagenes = const [],
    this.servicios = const [],
    this.activa = true,
  });

  Hosteria copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? direccion,
    double? latitud,
    double? longitud,
    String? telefono,
    String? email,
    String? sitioWeb,
    double? rating,
    List<String>? imagenes,
    List<String>? servicios,
    bool? activa,
  }) {
    return Hosteria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      rating: rating ?? this.rating,
      imagenes: imagenes ?? this.imagenes,
      servicios: servicios ?? this.servicios,
      activa: activa ?? this.activa,
    );
  }
}
