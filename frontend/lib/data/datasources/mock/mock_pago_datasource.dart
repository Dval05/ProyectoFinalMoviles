
import '../../models/pago_model.dart';
import '../firebase/pago_datasource.dart';

class MockPagoDataSource implements PagoDataSource {
  final List<PagoModel> _pagos = [];

  @override
  Future<PagoModel> procesarPago(PagoModel pago) async {
    await Future.delayed(const Duration(seconds: 2));
    final nuevoPago = PagoModel(
      id: 'pag-\${DateTime.now().millisecondsSinceEpoch}',
      reservaId: pago.reservaId,
      usuarioId: pago.usuarioId,
      monto: pago.monto,
      metodo: pago.metodo,
      estado: 'completado', // Auto completado para mock
      referencia: 'MOCK-REF-\${DateTime.now().millisecondsSinceEpoch}',
      fechaPago: DateTime.now(),
    );
    _pagos.insert(0, nuevoPago);
    return nuevoPago;
  }

  @override
  Future<List<PagoModel>> getPagosPorUsuario(String usuarioId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _pagos.where((p) => p.usuarioId == usuarioId).toList();
  }

  @override
  Future<PagoModel?> getPagoPorReserva(String reservaId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final result = _pagos.where((p) => p.reservaId == reservaId).toList();
    if (result.isNotEmpty) return result.first;
    return null;
  }
}
