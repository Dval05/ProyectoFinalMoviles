import 'package:flutter/material.dart';
import '../../../domain/entities/pago.dart';
import '../../../domain/usecases/pago/procesar_pago_usecase.dart';
import '../../../domain/usecases/pago/get_historial_pagos_usecase.dart';

class PagoViewModel extends ChangeNotifier {
  final ProcesarPagoUseCase _procesarPagoUseCase;
  final GetHistorialPagosUseCase _getHistorialPagosUseCase;

  List<Pago> _pagos = [];
  bool _isLoading = false;
  String? _errorMessage;

  PagoViewModel({
    required this._procesarPagoUseCase,
    required this._getHistorialPagosUseCase,
  });

  List<Pago> get pagos => _pagos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> procesarPago(Pago pago) async {
    _setLoading(true);
    try {
      // Simulación de retraso de pasarela de pagos
      await Future.delayed(const Duration(seconds: 2));
      
      final pagoProcesado = await _procesarPagoUseCase(pago.copyWith(estado: 'completado'));
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
      _pagos = await _getHistorialPagosUseCase(usuarioId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
