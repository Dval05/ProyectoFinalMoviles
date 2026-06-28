import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/firebase/reserva_datasource.dart';
import '../models/reserva_model.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  ReservaRepositoryImpl(this._dataSource);
  final ReservaDataSource _dataSource;

  @override
  Future<Reserva> crearReserva(Reserva reserva) async {
    // Convierte Entity a Model para persistirlo
    final model = ReservaModel.fromEntity(reserva);
    return _dataSource.crearReserva(model);
  }

  @override
  Future<List<Reserva>> getReservasPorUsuario(String usuarioId) async {
    return _dataSource.getReservasPorUsuario(usuarioId);
  }

  @override
  Future<List<Reserva>> getTodasLasReservas() async {
    return _dataSource.getTodasLasReservas();
  }

  @override
  Future<List<Reserva>> getReservasPorHabitacion(String habitacionId) async {
    return _dataSource.getReservasPorHabitacion(habitacionId);
  }

  @override
  Future<Reserva> getReservaById(String id) async {
    return _dataSource.getReservaById(id);
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    return _dataSource.actualizarEstado(reservaId, 'cancelada');
  }

  @override
  Future<void> actualizarEstado(String reservaId, String nuevoEstado) async {
    return _dataSource.actualizarEstado(reservaId, nuevoEstado);
  }
}
