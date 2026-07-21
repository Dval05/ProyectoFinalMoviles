import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/failures.dart';

class WeatherApi {
  // Sigchos location using Open-Meteo API
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast?latitude=-0.7022&longitude=-78.8828&current_weather=true';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        return {
          'temperature': double.tryParse(current['temperature'].toString()) ?? 0.0,
          'weathercode': int.tryParse(current['weathercode'].toString()) ?? 0,
        };
      } else {
        throw const ServerFailure('Error al obtener el clima de Sigchos');
      }
    } catch (e) {
      throw const ServerFailure('No se pudo conectar al servidor de clima');
    }
  }
}
