import 'env.dart';

/// Constantes generales de la aplicación HostSigchos
class AppConstants {
  // Nombre de la app
  static const String appName = 'HostSigchos';
  static const String appTagline = 'Reservas en Sigchos';

  // Support & URLs
  static String get whatsappSupportNumber => Env.supportPhone;
  static String get supportEmail => Env.supportEmail;
  static const String termsUrl = 'https://hostsigchos.web.app/terminos.html';
  static const String privacyUrl = 'https://hostsigchos.web.app/politicas.html';
  static const String accountDeletionUrl = 'https://hostsigchos.web.app/eliminar_cuenta.html';


  // Google Geocoding API
  static const String geocodingBaseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  // Coordenadas de Sigchos (centro del mapa por defecto)
  static const double sigchosLatitud = -0.7033;
  static const double sigchosLongitud = -78.8878;
  static const double defaultZoom = 13;

  // Configuración de reservas
  static const int maxHuespedes = 8;
  static const int maxNochesReserva = 30;
  static const int horaCheckIn = 14; // 2:00 PM
  static const int horaCheckOut = 12; // 12:00 PM

  // Moneda
  static const String moneda = 'USD';
  static const String simboloMoneda = r'$';
}
