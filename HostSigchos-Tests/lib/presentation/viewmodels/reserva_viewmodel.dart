import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/error_handler.dart';
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
      // Agregamos timeout para que si la BD no responde, no se quede colgado
      _reservaActual = await _crearReservaUseCase(reserva).timeout(const Duration(seconds: 10));
      
      try {
        // Simular envío de notificación real al usuario
        // Agregamos timeout a Firestore por si la instancia por defecto no responde
        await _enviarNotificacion(
          reserva.usuarioId,
          'Reserva Creada Exitosamente',
          'Tu reserva ha sido creada y está pendiente de confirmación. Revisa los detalles.',
        );
      } catch (e) {
        debugPrint('Error al enviar notificación simulada: $e');
        // No bloqueamos el flujo si la notificación falla
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
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
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
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
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarEstadoReserva(
    String reservaId,
    String nuevoEstado,
  ) async {
    _setLoading(true);
    try {
      await _actualizarEstadoReservaUseCase(reservaId, nuevoEstado);
      _errorMessage = null;
      if (_reservaActual?.id == reservaId) {
        _reservaActual = _reservaActual!.copyWith(estado: nuevoEstado);
      }
      
      final index = _reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        final nuevaLista = List<Reserva>.from(_reservas);
        nuevaLista[index] = nuevaLista[index].copyWith(estado: nuevoEstado);
        _reservas = nuevaLista;
        
        // Enviar notificación según el nuevo estado
        String titulo = 'Actualización de Reserva';
        String mensaje = 'El estado de tu reserva ha cambiado a $nuevoEstado.';
        
        if (nuevoEstado == 'en_revision') {
          titulo = 'Reserva en revisión';
          mensaje = 'Estamos revisando tu comprobante y pronto confirmaremos tu reserva.';
        } else if (nuevoEstado == 'confirmada') {
          titulo = 'Reserva confirmada';
          mensaje = '¡Tu reserva ha sido confirmada con éxito! Te esperamos.';
        } else if (nuevoEstado == 'cancelada') {
          titulo = 'Reserva cancelada';
          mensaje = 'Tu reserva ha sido cancelada.';
        }
        
        await _enviarNotificacion(_reservas[index].usuarioId, titulo, mensaje);
      }
      
      await cargarTodasLasReservas();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
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
      await _cancelarReservaUseCase(
        reservaId,
      ).timeout(const Duration(seconds: 5));
      final index = _reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        final nuevaLista = List<Reserva>.from(_reservas);
        nuevaLista[index] = nuevaLista[index].copyWith(estado: 'cancelada');
        _reservas = nuevaLista;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> existeSolapamiento(
    String usuarioId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    _setLoading(true);
    try {
      final historial = await _getHistorialReservasUseCase(usuarioId);
      final reservasPropias = historial
          .where((r) => r.estaActiva && !r.esParaOtraPersona)
          .toList();

      for (final r in reservasPropias) {
        if (checkIn.isBefore(r.fechaCheckOut) &&
            checkOut.isAfter(r.fechaCheckIn)) {
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

  Future<bool> verificarDisponibilidad(
    Habitacion habitacion,
    DateTime checkIn,
    DateTime checkOut,
    int cantidadSolicitada,
  ) async {
    _setLoading(true);
    try {
      return await _checkDisponibilidadUseCase(
        habitacion.id,
        checkIn,
        checkOut,
        cantidadSolicitada,
      );
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
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _enviarNotificacion(String usuarioId, String titulo, String mensaje) async {
    try {
      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'hostsigchos',
      ).collection('notificaciones').add({
        'usuarioId': usuarioId,
        'titulo': titulo,
        'mensaje': mensaje,
        'fecha': FieldValue.serverTimestamp(),
        'leida': false,
        'tipo': 'reserva',
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error enviando notificación: $e');
    }
  }
}
