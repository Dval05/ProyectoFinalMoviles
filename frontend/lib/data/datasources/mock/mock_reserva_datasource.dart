
import '../../models/reserva_model.dart';
import '../firebase/reserva_datasource.dart';

class MockReservaDataSource implements ReservaDataSource {
  final List<ReservaModel> _reservas = [];

  @override
  Future<ReservaModel> crearReserva(ReservaModel reserva) async {
    await Future.delayed(const Duration(seconds: 1));
    final nuevaReserva = ReservaModel(
      id: 'res-${DateTime.now().millisecondsSinceEpoch}',
      usuarioId: reserva.usuarioId,
      hosteriaId: reserva.hosteriaId,
      habitacionId: reserva.habitacionId,
      fechaCheckIn: reserva.fechaCheckIn,
      fechaCheckOut: reserva.fechaCheckOut,
      numHuespedes: reserva.numHuespedes,
      precioTotal: reserva.precioTotal,
      estado: 'confirmada', // Auto confirmada para mock
      fechaCreacion: DateTime.now(),
      notas: reserva.notas,
      nombreHosteria: reserva.nombreHosteria ?? 'Hostería Mock',
      tipoHabitacion: reserva.tipoHabitacion ?? 'Habitación Mock',
    );
    _reservas.insert(0, nuevaReserva);
    return nuevaReserva;
  }

  @override
  Future<List<ReservaModel>> getReservasPorUsuario(String usuarioId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _reservas.where((r) => r.usuarioId == usuarioId).toList();
  }

  @override
  Future<ReservaModel> getReservaById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _reservas.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Reserva no encontrada'),
    );
  }

  @override
  Future<void> actualizarEstado(String reservaId, String nuevoEstado) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _reservas.indexWhere((r) => r.id == reservaId);
    if (index != -1) {
      final old = _reservas[index];
      _reservas[index] = ReservaModel(
        id: old.id,
        usuarioId: old.usuarioId,
        hosteriaId: old.hosteriaId,
        habitacionId: old.habitacionId,
        fechaCheckIn: old.fechaCheckIn,
        fechaCheckOut: old.fechaCheckOut,
        numHuespedes: old.numHuespedes,
        precioTotal: old.precioTotal,
        estado: nuevoEstado,
        fechaCreacion: old.fechaCreacion,
        notas: old.notas,
        nombreHosteria: old.nombreHosteria,
        tipoHabitacion: old.tipoHabitacion,
      );
    }
  }
}
