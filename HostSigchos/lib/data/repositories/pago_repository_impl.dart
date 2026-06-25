import '../../domain/entities/pago.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/firebase/pago_datasource.dart';
import '../models/pago_model.dart';

class PagoRepositoryImpl implements PagoRepository {

  PagoRepositoryImpl(this._dataSource);
  final PagoDataSource _dataSource;

  @override
  Future<Pago> procesarPago(Pago pago) async {
    final model = PagoModel.fromEntity(pago);
    return _dataSource.procesarPago(model);
  }

  @override
  Future<List<Pago>> getPagosPorUsuario(String usuarioId) async {
    return _dataSource.getPagosPorUsuario(usuarioId);
  }

  @override
  Future<Pago?> getPagoPorReserva(String reservaId) async {
    return _dataSource.getPagoPorReserva(reservaId);
  }

  @override
  Future<void> actualizarEstadoPago(String pagoId, String nuevoEstado) async {
    return _dataSource.actualizarEstadoPago(pagoId, nuevoEstado);
  }
}
