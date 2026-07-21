class Resena {
  const Resena({
    required this.id,
    required this.hosteriaId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.comentario,
    required this.rating,
    required this.fecha,
  });

  final String id;
  final String hosteriaId;
  final String usuarioId;
  final String nombreUsuario;
  final String comentario;
  final double rating;
  final DateTime fecha;

  Resena copyWith({
    String? id,
    String? hosteriaId,
    String? usuarioId,
    String? nombreUsuario,
    String? comentario,
    double? rating,
    DateTime? fecha,
  }) {
    return Resena(
      id: id ?? this.id,
      hosteriaId: hosteriaId ?? this.hosteriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      comentario: comentario ?? this.comentario,
      rating: rating ?? this.rating,
      fecha: fecha ?? this.fecha,
    );
  }
}
