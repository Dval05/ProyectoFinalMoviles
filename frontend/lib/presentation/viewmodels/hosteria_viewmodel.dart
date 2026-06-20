import 'package:flutter/material.dart';
import '../../../domain/entities/hosteria.dart';
import '../../../domain/usecases/hosteria/get_hosterias_usecase.dart';
import '../../../domain/usecases/hosteria/get_hosteria_detail_usecase.dart';

class HosteriaViewModel extends ChangeNotifier {
  final GetHosteriasUseCase _getHosteriasUseCase;
  final GetHosteriaDetailUseCase _getHosteriaDetailUseCase;

  List<Hosteria> _hosterias = [];
  List<Hosteria> _hosteriasFiltradas = [];
  Hosteria? _hosteriaSeleccionada;
  bool _isLoading = false;
  String? _errorMessage;

  HosteriaViewModel({
    required this._getHosteriasUseCase,
    required this._getHosteriaDetailUseCase,
  });

  List<Hosteria> get hosterias => _hosteriasFiltradas.isEmpty && _errorMessage == null ? _hosterias : _hosteriasFiltradas;
  Hosteria? get hosteriaSeleccionada => _hosteriaSeleccionada;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> cargarHosterias() async {
    _setLoading(true);
    try {
      _hosterias = await _getHosteriasUseCase();
      _hosteriasFiltradas = _hosterias;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void filtrarHosterias(String query) {
    if (query.isEmpty) {
      _hosteriasFiltradas = _hosterias;
    } else {
      final searchLower = query.toLowerCase();
      _hosteriasFiltradas = _hosterias
          .where((h) =>
              h.nombre.toLowerCase().contains(searchLower) ||
              h.descripcion.toLowerCase().contains(searchLower) ||
              h.direccion.toLowerCase().contains(searchLower))
          .toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
