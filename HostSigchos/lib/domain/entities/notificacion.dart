class NotificacionApp {
  const NotificacionApp({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.leida,
    required this.tipo,
  });

  final String id;
  final String usuarioId;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final String tipo; // 'reserva', 'oferta', 'sistema'

  NotificacionApp copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    String? mensaje,
    DateTime? fecha,
    bool? leida,
    String? tipo,
  }) {
    return NotificacionApp(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      fecha: fecha ?? this.fecha,
      leida: leida ?? this.leida,
      tipo: tipo ?? this.tipo,
    );
  }
}
