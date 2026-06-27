import 'package:flutter/material.dart';

import '../../domain/entities/habitacion.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import '../../domain/usecases/reserva/actualizar_estado_reserva_usecase.dart';
import '../../domain/usecases/reserva/cancelar_reserva_usecase.dart';
import '../../domain/usecases/reserva/crear_reserva_usecase.dart';
import '../../domain/usecases/reserva/get_historial_reservas_usecase.dart';
import '../../domain/usecases/reserva/get_todas_las_reservas_usecase.dart';

class ReservaViewModel extends ChangeNotifier {

  ReservaViewModel({
    required this._crearReservaUseCase,
    required this._getHistorialReservasUseCase,
    required this._getTodasLasReservasUseCase,
    required this._actualizarEstadoReservaUseCase,
    required this._cancelarReservaUseCase,
    required this._checkDisponibilidadUseCase,
  });
  final CrearReservaUseCase _crearReservaUseCase;
  final GetHistorialReservasUseCase _getHistorialReservasUseCase;
  final GetTodasLasReservasUseCase _getTodasLasReservasUseCase;
  final ActualizarEstadoReservaUseCase _actualizarEstadoReservaUseCase;
  final CancelarReservaUseCase _cancelarReservaUseCase;
  final CheckDisponibilidadUseCase _checkDisponibilidadUseCase;

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

  Future<void> cargarTodasLasReservas() async {
    _setLoading(true);
    try {
      _reservas = await _getTodasLasReservasUseCase();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarEstadoReserva(String reservaId, String nuevoEstado) async {
    _setLoading(true);
    try {
      await _actualizarEstadoReservaUseCase(reservaId, nuevoEstado);
      _errorMessage = null;
      if (_reservaActual?.id == reservaId) {
        _reservaActual = _reservaActual!.copyWith(estado: nuevoEstado);
      }
      await cargarTodasLasReservas();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica si hay reservas pendientes y las cancela si expiraron
  Future<void> _verificarReservasNoConfirmadas() async {
    final ahora = DateTime.now();
    for (int i = 0; i < _reservas.length; i++) {
      final reserva = _reservas[i];
      if (reserva.estado == 'pendiente' || reserva.estado == 'en_revision') {
        // Límite: 48 horas después de la creación de la reserva
        final limiteConfirmacion = reserva.fechaCreacion.add(
          const Duration(hours: 48),
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

  /// Cancela una reserva manualmente por el usuario
  Future<bool> cancelarReservaUsuario(String reservaId) async {
    _setLoading(true);
    try {
      await _cancelarReservaUseCase(reservaId).timeout(const Duration(seconds: 5));
      final index = _reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        final nuevaLista = List<Reserva>.from(_reservas);
        nuevaLista[index] = nuevaLista[index].copyWith(estado: 'cancelada');
        _reservas = nuevaLista;
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

  Future<bool> existeSolapamiento(String usuarioId, DateTime checkIn, DateTime checkOut) async {
    _setLoading(true);
    try {
      final historial = await _getHistorialReservasUseCase(usuarioId);
      final reservasPropias = historial.where((r) => 
        r.estaActiva && !r.esParaOtraPersona
      ).toList();

      for (final r in reservasPropias) {
        if (checkIn.isBefore(r.fechaCheckOut) && checkOut.isAfter(r.fechaCheckIn)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error al verificar solapamiento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verificarDisponibilidad(Habitacion habitacion, DateTime checkIn, DateTime checkOut, int cantidadSolicitada) async {
    _setLoading(true);
    try {
      return await _checkDisponibilidadUseCase(habitacion.id, checkIn, checkOut, cantidadSolicitada);
    } catch (e) {
      debugPrint('Error al verificar disponibilidad real: $e');
      return false;
    } finally {
      _setLoading(false);
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
