import '../entities/pago.dart';

/// Interfaz del repositorio de pagos
abstract class PagoRepository {
  /// Procesar un nuevo pago
  Future<Pago> procesarPago(Pago pago);

  /// Obtener historial de pagos del usuario
  Future<List<Pago>> getPagosPorUsuario(String usuarioId);

  /// Obtener pago por ID de reserva
  Future<Pago?> getPagoPorReserva(String reservaId);

  /// Actualizar estado de un pago
  Future<void> actualizarEstadoPago(String pagoId, String nuevoEstado);
}
