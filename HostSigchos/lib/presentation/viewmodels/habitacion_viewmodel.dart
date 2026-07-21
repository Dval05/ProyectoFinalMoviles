import 'package:flutter/material.dart';

import '../../core/utils/error_handler.dart';
import '../../domain/entities/habitacion.dart';
import '../../domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import '../../domain/usecases/habitacion/get_habitaciones_usecase.dart';
import '../../domain/usecases/habitacion/get_todas_las_habitaciones_usecase.dart';

class HabitacionViewModel extends ChangeNotifier {
  HabitacionViewModel({
    required this.getHabitacionesUseCase,
    required this.checkDisponibilidadUseCase,
    required this.getTodasLasHabitacionesUseCase,
  });
  final GetHabitacionesUseCase getHabitacionesUseCase;
  final CheckDisponibilidadUseCase checkDisponibilidadUseCase;
  final GetTodasLasHabitacionesUseCase getTodasLasHabitacionesUseCase;

  List<Habitacion> _habitaciones = [];
  List<Habitacion> _todasLasHabitaciones = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Estado temporal de disponibilidad
  final Map<String, bool> _disponibilidadPorHabitacion = {};

  List<Habitacion> get habitaciones => _habitaciones;
  List<Habitacion> get todasLasHabitaciones => _todasLasHabitaciones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool? getDisponibilidad(String habitacionId) =>
      _disponibilidadPorHabitacion[habitacionId];

  Future<void> cargarTodasLasHabitaciones() async {
    _setLoading(true);
    try {
      _todasLasHabitaciones = await getTodasLasHabitacionesUseCase();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarHabitacionesPorHosteria(String hosteriaId) async {
    _setLoading(true);
    _disponibilidadPorHabitacion.clear(); // Limpiar disponibilidad previa
    try {
      _habitaciones = await getHabitacionesUseCase(hosteriaId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verificarDisponibilidadTodas(
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    _setLoading(true);
    try {
      for (final hab in _habitaciones) {
        final disponible = await checkDisponibilidadUseCase(
          hab.id,
          checkIn,
          checkOut,
          1,
        );
        _disponibilidadPorHabitacion[hab.id] = disponible;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
