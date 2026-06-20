import '../../domain/entities/reserva.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/firebase/reserva_datasource.dart';
import '../models/reserva_model.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaDataSource _dataSource;

  ReservaRepositoryImpl(this._dataSource);

  @override
  Future<Reserva> crearReserva(Reserva reserva) async {
    // Convierte Entity a Model para persistirlo
    final model = ReservaModel.fromEntity(reserva);
    return await _dataSource.crearReserva(model);
  }

  @override
  Future<List<Reserva>> getReservasPorUsuario(String usuarioId) async {
    return await _dataSource.getReservasPorUsuario(usuarioId);
  }

  @override
  Future<Reserva> getReservaById(String id) async {
    return await _dataSource.getReservaById(id);
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    return await _dataSource.actualizarEstado(reservaId, 'cancelada');
  }

  @override
  Future<void> actualizarEstado(String reservaId, String nuevoEstado) async {
    return await _dataSource.actualizarEstado(reservaId, nuevoEstado);
  }
}
