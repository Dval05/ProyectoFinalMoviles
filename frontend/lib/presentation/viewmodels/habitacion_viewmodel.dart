import 'package:flutter/material.dart';
import '../../../domain/entities/habitacion.dart';
import '../../../domain/usecases/habitacion/get_habitaciones_usecase.dart';
import '../../../domain/usecases/habitacion/check_disponibilidad_usecase.dart';

class HabitacionViewModel extends ChangeNotifier {
  final GetHabitacionesUseCase _getHabitacionesUseCase;
  final CheckDisponibilidadUseCase _checkDisponibilidadUseCase;

  List<Habitacion> _habitaciones = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Estado temporal de disponibilidad
  final Map<String, bool> _disponibilidadPorHabitacion = {};

  HabitacionViewModel({
    required this._getHabitacionesUseCase,
    required this._checkDisponibilidadUseCase,
  });

  List<Habitacion> get habitaciones => _habitaciones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool? getDisponibilidad(String habitacionId) => 
      _disponibilidadPorHabitacion[habitacionId];

  Future<void> cargarHabitacionesPorHosteria(String hosteriaId) async {
    _setLoading(true);
    _disponibilidadPorHabitacion.clear(); // Limpiar disponibilidad previa
    try {
      _habitaciones = await _getHabitacionesUseCase(hosteriaId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verificarDisponibilidadTodas(DateTime checkIn, DateTime checkOut) async {
    _setLoading(true);
    try {
      for (var hab in _habitaciones) {
        final disponible = await _checkDisponibilidadUseCase(hab.id, checkIn, checkOut);
        _disponibilidadPorHabitacion[hab.id] = disponible;
      }
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
