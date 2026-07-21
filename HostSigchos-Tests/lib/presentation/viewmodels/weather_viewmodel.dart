import 'package:flutter/material.dart';
import '../../core/utils/error_handler.dart';
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
      _temperature = (weatherData['temperature'] as num?)?.toDouble();
      _weathercode = weatherData['weathercode'] as int?;
    } catch (e) {
      _errorMessage = ErrorHandler.getFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper para obtener icono según el código WWO (World Weather Online)
  IconData getWeatherIcon() {
    if (_weathercode == null) return Icons.cloud_outlined;

    // Códigos WWO (usados por wttr.in)
    if (_weathercode == 113) {
      return Icons.wb_sunny; // Despejado
    }
    if (_weathercode == 116 || _weathercode == 119 || _weathercode == 122) {
      return Icons.wb_cloudy; // Nublado
    }
    if (_weathercode! >= 143 && _weathercode! <= 314) {
      return Icons.water_drop; // Lluvia / Neblina / Llovizna
    }
    if (_weathercode! >= 317 && _weathercode! <= 350) {
      return Icons.ac_unit; // Nieve / Granizo
    }
    if (_weathercode! >= 353) {
      return Icons.water_drop; // Tormenta / Lluvia fuerte
    }

    return Icons.cloud; // Por defecto
  }
}
