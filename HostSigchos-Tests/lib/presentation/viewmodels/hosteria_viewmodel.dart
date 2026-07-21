import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/error_handler.dart';
import '../../domain/entities/hosteria.dart';
import '../../domain/usecases/habitacion/get_habitaciones_usecase.dart';
import '../../domain/usecases/hosteria/get_hosteria_detail_usecase.dart';
import '../../domain/usecases/hosteria/get_hosterias_usecase.dart';

enum OrdenHosterias {
  ninguno,
  precioMenorAMayor,
  precioMayorAMenor,
  nombreAZ,
  nombreZA,
  ratingMayorAMenor,
  ratingMenorAMayor,
}

class HosteriaViewModel extends ChangeNotifier {
  HosteriaViewModel({
    required this._getHosteriasUseCase,
    required this._getHosteriaDetailUseCase,
    required this._getHabitacionesUseCase,
  });
  final GetHosteriasUseCase _getHosteriasUseCase;
  final GetHosteriaDetailUseCase _getHosteriaDetailUseCase;
  final GetHabitacionesUseCase _getHabitacionesUseCase;

  List<Hosteria> _hosterias = [];
  List<Hosteria> _hosteriasFiltradas = [];
  Hosteria? _hosteriaSeleccionada;
  bool _isLoading = false;
  String? _errorMessage;
  OrdenHosterias _ordenActual = OrdenHosterias.ninguno;

  List<Hosteria> get todasHosterias => _hosterias;
  List<Hosteria> get hosterias => _hosteriasFiltradas;
  Hosteria? get hosteriaSeleccionada => _hosteriaSeleccionada;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Hosteria> get destacadas {
    final list = List<Hosteria>.from(_hosterias)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(3).toList();
  }

  List<Hosteria> obtenerCercanas(double lat, double lng, {int count = 4}) {
    if (_hosterias.isEmpty) return [];
    final list = List<Hosteria>.from(_hosterias)
      ..sort((a, b) {
        final distA = Geolocator.distanceBetween(
          lat,
          lng,
          a.latitud,
          a.longitud,
        );
        final distB = Geolocator.distanceBetween(
          lat,
          lng,
          b.latitud,
          b.longitud,
        );
        return distA.compareTo(distB);
      });
    return list.take(count).toList();
  }

  Future<void> cargarHosterias() async {
    _setLoading(true);
    try {
      final rawHosterias = await _getHosteriasUseCase();
      final processedFutures = rawHosterias.map((h) async {
        final habitaciones = await _getHabitacionesUseCase(h.id);
        if (habitaciones.isNotEmpty) {
          final total = habitaciones.fold<double>(
            0,
            (sum, r) => sum + r.precioPorNoche,
          );
          final avg = total / habitaciones.length;
          return h.copyWith(precioPorNoche: avg);
        }
        return h;
      });
      _hosterias = await Future.wait(processedFutures);
      _hosteriasFiltradas = _hosterias;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarHosteriaDetalle(String id) async {
    _setLoading(true);
    try {
      _hosteriaSeleccionada = await _getHosteriaDetailUseCase(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  String _searchQuery = '';
  DateTimeRange? _filtroFechas;
  RangeValues? _filtroPrecios;

  DateTimeRange? get filtroFechas => _filtroFechas;
  RangeValues? get filtroPrecios => _filtroPrecios;
  OrdenHosterias get ordenActual => _ordenActual;

  void filtrarHosterias(String query) {
    _searchQuery = query;
    _aplicarFiltrosCombinados();
  }

  void cambiarOrden(OrdenHosterias orden) {
    _ordenActual = orden;
    _aplicarFiltrosCombinados();
  }

  void aplicarFiltrosAvanzados({
    DateTimeRange? fechas,
    RangeValues? precios,
  }) {
    _filtroFechas = fechas;
    _filtroPrecios = precios;
    _aplicarFiltrosCombinados();
  }

  void limpiarFiltrosAvanzados() {
    _filtroFechas = null;
    _filtroPrecios = null;
    _ordenActual = OrdenHosterias.ninguno;
    _aplicarFiltrosCombinados();
  }

  void _aplicarFiltrosCombinados() {
    _hosteriasFiltradas = _hosterias.where((h) {
      // 1. Filtro por texto libre
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!h.nombre.toLowerCase().contains(searchLower) &&
            !h.descripcion.toLowerCase().contains(searchLower) &&
            !h.direccion.toLowerCase().contains(searchLower)) {
          return false;
        }
      }
      // 3. Filtro por Precios
      if (_filtroPrecios != null) {
        if (h.precioPorNoche < _filtroPrecios!.start ||
            h.precioPorNoche > _filtroPrecios!.end) {
          return false;
        }
      }

      // 4. Filtro por Fechas
      // (Aquí deberíamos verificar la disponibilidad real comparando con reservaciones si tuviéramos esos datos cargados en Hosteria, por ahora es ilustrativo o asume disponibilidad si no se choca con h.fechasOcupadas)

      return true;
    }).toList();

    // 5. Aplicar ordenamiento
    switch (_ordenActual) {
      case OrdenHosterias.precioMenorAMayor:
        _hosteriasFiltradas.sort(
          (a, b) => a.precioPorNoche.compareTo(b.precioPorNoche),
        );
      case OrdenHosterias.precioMayorAMenor:
        _hosteriasFiltradas.sort(
          (a, b) => b.precioPorNoche.compareTo(a.precioPorNoche),
        );
      case OrdenHosterias.nombreAZ:
        _hosteriasFiltradas.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      case OrdenHosterias.nombreZA:
        _hosteriasFiltradas.sort(
          (a, b) => b.nombre.toLowerCase().compareTo(a.nombre.toLowerCase()),
        );
      case OrdenHosterias.ratingMayorAMenor:
        _hosteriasFiltradas.sort((a, b) => b.rating.compareTo(a.rating));
      case OrdenHosterias.ratingMenorAMayor:
        _hosteriasFiltradas.sort((a, b) => a.rating.compareTo(b.rating));
      case OrdenHosterias.ninguno:
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
