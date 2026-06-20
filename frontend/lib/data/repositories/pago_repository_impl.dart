import '../../domain/entities/pago.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/firebase/pago_datasource.dart';
import '../models/pago_model.dart';

class PagoRepositoryImpl implements PagoRepository {
  final PagoDataSource _dataSource;

  PagoRepositoryImpl(this._dataSource);

  @override
  Future<Pago> procesarPago(Pago pago) async {
    final model = PagoModel.fromEntity(pago);
    return await _dataSource.procesarPago(model);
  }

  @override
  Future<List<Pago>> getPagosPorUsuario(String usuarioId) async {
    return await _dataSource.getPagosPorUsuario(usuarioId);
  }

  @override
  Future<Pago?> getPagoPorReserva(String reservaId) async {
    return await _dataSource.getPagoPorReserva(reservaId);
  }
}
