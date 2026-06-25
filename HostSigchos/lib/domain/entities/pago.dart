/// Entidad de dominio: Pago de una reserva
class Pago {

  const Pago({
    required this.id,
    required this.reservaId,
    required this.usuarioId,
    required this.monto,
    required this.metodo,
    required this.referencia, required this.fechaPago, this.estado = 'pendiente',
    this.comprobanteUrl,
  });
  final String id;
  final String reservaId;
  final String usuarioId;
  final double monto;
  final String metodo;
  final String estado;
  final String referencia;
  final DateTime fechaPago;
  final String? comprobanteUrl;

  bool get esCompletado => estado == 'completado';

  Pago copyWith({
    String? id,
    String? reservaId,
    String? usuarioId,
    double? monto,
    String? metodo,
    String? estado,
    String? referencia,
    DateTime? fechaPago,
    String? comprobanteUrl,
  }) {
    return Pago(
      id: id ?? this.id,
      reservaId: reservaId ?? this.reservaId,
      usuarioId: usuarioId ?? this.usuarioId,
      monto: monto ?? this.monto,
      metodo: metodo ?? this.metodo,
      estado: estado ?? this.estado,
      referencia: referencia ?? this.referencia,
      fechaPago: fechaPago ?? this.fechaPago,
      comprobanteUrl: comprobanteUrl ?? this.comprobanteUrl,
    );
  }
}
