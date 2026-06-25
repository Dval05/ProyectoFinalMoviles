import 'package:flutter/material.dart';

import '../../domain/entities/reserva.dart';
import '../../domain/usecases/reserva/cancelar_reserva_usecase.dart';
import '../../domain/usecases/reserva/crear_reserva_usecase.dart';
import '../../domain/usecases/reserva/get_historial_reservas_usecase.dart';

class ReservaViewModel extends ChangeNotifier {

  ReservaViewModel({
    required this._crearReservaUseCase,
    required this._getHistorialReservasUseCase,
    required this._cancelarReservaUseCase,
  });
  final CrearReservaUseCase _crearReservaUseCase;
  final GetHistorialReservasUseCase _getHistorialReservasUseCase;
  final CancelarReservaUseCase _cancelarReservaUseCase;

  List<Reserva> _reservas = [];
  Reserva? _reservaActual;
  bool _isLoading = false;
  String? _errorMessage;

  List<Reserva> get reservas => _reservas;
  Reserva? get reservaActual => _reservaActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> crearReserva(Reserva reserva) async {
    _setLoading(true);
    try {
      _reservaActual = await _crearReservaUseCase(reserva);
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
      _reservas = await _getHistorialReservasUseCase(usuarioId);
      await _verificarReservasNoConfirmadas();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica y cancela reservas que no han sido confirmadas hasta un día antes del check-in
  Future<void> _verificarReservasNoConfirmadas() async {
    final ahora = DateTime.now();
    for (int i = 0; i < _reservas.length; i++) {
      final reserva = _reservas[i];
      if (reserva.estado == 'pendiente' || reserva.estado == 'en_revision') {
        // Límite: 1 día antes del check-in
        final limiteConfirmacion = reserva.fechaCheckIn.subtract(
          const Duration(days: 1),
        );
        if (ahora.isAfter(limiteConfirmacion)) {
          try {
            await _cancelarReservaUseCase(reserva.id);
            _reservas[i] = reserva.copyWith(estado: 'cancelada');
          } catch (e) {
            debugPrint(
              'Error al cancelar reserva no confirmada ${reserva.id}: $e',
            );
          }
        }
      }
    }
  }

  Future<bool> cancelarReserva(String reservaId) async {
    _setLoading(true);
    try {
      await _cancelarReservaUseCase(reservaId);
      // Actualizar estado local
      final index = _reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        _reservas[index] = _reservas[index].copyWith(estado: 'cancelada');
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
