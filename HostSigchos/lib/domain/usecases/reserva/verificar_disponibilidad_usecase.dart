import '../../entities/habitacion.dart';
import '../../repositories/reserva_repository.dart';

class VerificarDisponibilidadUseCase {
  VerificarDisponibilidadUseCase(this._repository);
  final ReservaRepository _repository;

  Future<bool> call(Habitacion habitacion, DateTime checkIn, DateTime checkOut, int cantidadSolicitada) async {
    // 1. Obtener todas las reservas de esta habitación
    final reservas = await _repository.getReservasPorHabitacion(habitacion.id);
    
    // 2. Filtrar reservas activas que se crucen con estas fechas
    int habitacionesOcupadas = 0;
    
    for (final r in reservas) {
      if (r.estaActiva) {
        // Lógica de solapamiento: (CheckIn_A < CheckOut_B) && (CheckOut_A > CheckIn_B)
        if (checkIn.isBefore(r.fechaCheckOut) && checkOut.isAfter(r.fechaCheckIn)) {
          habitacionesOcupadas += r.numHabitaciones;
        }
      }
    }
    
    // 3. Verificar si hay suficientes habitaciones disponibles
    final int disponibles = habitacion.cantidadTotal - habitacionesOcupadas;
    return disponibles >= cantidadSolicitada;
  }
}
