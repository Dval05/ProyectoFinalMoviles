import 'package:flutter/material.dart';
import '../../data/datasources/api/weather_api.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._weatherApi);
  final WeatherApi _weatherApi;

  bool _isLoading = false;
  String? _errorMessage;
  double? _temperature;
  int? _weathercode; // Useful for showing different icons (sun, rain, cloud)

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get temperature => _temperature;
  int? get weathercode => _weathercode;

  Future<void> fetchWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weatherData = await _weatherApi.getCurrentWeather();
      _temperature = weatherData['temperature'] as double?;
      _weathercode = weatherData['weathercode'] as int?;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper para obtener icono según el código WMO (World Meteorological Organization)
  IconData getWeatherIcon() {
    if (_weathercode == null) return Icons.cloud_outlined;

    // Simplificación de códigos WMO
    if (_weathercode == 0) {
      return Icons.wb_sunny; // Despejado
    }
    if (_weathercode! > 0 && _weathercode! <= 3) {
      return Icons.wb_cloudy; // Parcialmente nublado
    }
    if (_weathercode! >= 51 && _weathercode! <= 67) {
      return Icons.water_drop; // Lluvia
    }
    if (_weathercode! >= 71 && _weathercode! <= 77) {
      return Icons.ac_unit; // Nieve
    }
    if (_weathercode! >= 95) {
      return Icons.flash_on; // Tormenta
    }

    return Icons.cloud; // Por defecto
  }
}
