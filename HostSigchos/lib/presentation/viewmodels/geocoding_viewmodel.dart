import 'package:flutter/material.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/usecases/geocoding/get_direccion_usecase.dart';

class GeocodingViewModel extends ChangeNotifier {
  GeocodingViewModel({
    required this._getDireccionUseCase,
  });
  final GetDireccionUseCase _getDireccionUseCase;

  String? _direccionActual;
  bool _isLoading = false;
  String? _errorMessage;

  String? get direccionActual => _direccionActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> obtenerDireccion(double lat, double lng) async {
    _setLoading(true);
    try {
      _direccionActual = await _getDireccionUseCase(lat, lng);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
      _direccionActual = 'Ubicación desconocida';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
