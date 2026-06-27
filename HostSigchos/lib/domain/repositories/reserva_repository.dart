import '../entities/reserva.dart';

/// Interfaz del repositorio de reservas
abstract class ReservaRepository {
  /// Crear una nueva reserva
  Future<Reserva> crearReserva(Reserva reserva);

  /// Obtener historial de reservas del usuario
  Future<List<Reserva>> getTodasLasReservas();
  Future<List<Reserva>> getReservasPorUsuario(String usuarioId);

  /// Obtener reservas por habitacion
  Future<List<Reserva>> getReservasPorHabitacion(String habitacionId);

  /// Obtener detalle de una reserva
  Future<Reserva> getReservaById(String id);

  /// Cancelar una reserva
  Future<void> cancelarReserva(String reservaId);

  /// Actualizar estado de una reserva
  Future<void> actualizarEstado(String reservaId, String nuevoEstado);
}
