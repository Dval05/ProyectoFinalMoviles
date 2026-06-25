import 'package:flutter/material.dart';

import '../../domain/entities/pago.dart';
import '../../domain/usecases/pago/actualizar_estado_pago_usecase.dart';
import '../../domain/usecases/pago/get_historial_pagos_usecase.dart';
import '../../domain/usecases/pago/procesar_pago_usecase.dart';

class PagoViewModel extends ChangeNotifier {

  PagoViewModel({
    required this.procesarPagoUseCase,
    required this.getHistorialPagosUseCase,
    required this.actualizarEstadoPagoUseCase,
  });
  final ProcesarPagoUseCase procesarPagoUseCase;
  final GetHistorialPagosUseCase getHistorialPagosUseCase;
  final ActualizarEstadoPagoUseCase actualizarEstadoPagoUseCase;

  List<Pago> _pagos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pago> get pagos => _pagos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> procesarPago(Pago pago) async {
    _setLoading(true);
    try {
      // Simulación de retraso de pasarela de pagos
      await Future.delayed(const Duration(seconds: 2));

      // Para métodos que no son tarjeta, el estado es 'en_revision'
      // Para tarjeta, el estado es 'completado'
      final String estadoPago;
      if (pago.metodo == 'tarjeta') {
        estadoPago = 'completado';
      } else {
        estadoPago = 'en_revision';
      }

      final pagoProcesado = await procesarPagoUseCase(
        pago.copyWith(estado: estadoPago),
      );
      _pagos.insert(0, pagoProcesado);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarHistorial(String usuarioId) async {
    _setLoading(true);
    try {
      _pagos = await getHistorialPagosUseCase(usuarioId);
      // Verificar pagos expirados (más de 48 horas en 'en_revision')
      await _verificarPagosExpirados();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica pagos en estado 'en_revision' con más de 48 horas
  /// y los cambia a 'pendiente'
  Future<void> _verificarPagosExpirados() async {
    final ahora = DateTime.now();
    const limite48h = Duration(hours: 48);

    for (int i = 0; i < _pagos.length; i++) {
      final pago = _pagos[i];
      if (pago.estado == 'en_revision') {
        final diferencia = ahora.difference(pago.fechaPago);
        if (diferencia > limite48h) {
          try {
            await actualizarEstadoPagoUseCase(
              pago.id,
              'pendiente',
              reservaId: pago.reservaId,
            );
            // Actualizar el estado local
            _pagos[i] = pago.copyWith(estado: 'pendiente');
          } catch (e) {
            debugPrint('Error al actualizar pago expirado ${pago.id}: $e');
          }
        }
      }
    }
    notifyListeners();
  }

  /// Obtener el estado de pago para mostrar mensaje en UI
  String getMensajeEstadoPago(String metodo) {
    if (metodo == 'tarjeta') {
      return 'Pago procesado exitosamente';
    } else {
      return 'Tu pago está en revisión. Será verificado dentro de las próximas 48 horas. Si no se confirma, pasará a estado pendiente.';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
