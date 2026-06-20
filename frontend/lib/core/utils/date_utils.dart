import 'package:intl/intl.dart';

/// Utilidades para manejo de fechas en reservas
class AppDateUtils {
  /// Calcula el número de noches entre dos fechas
  static int calcularNoches(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  /// Formatea una fecha en formato legible: "18 jun. 2026"
  static String formatearFecha(DateTime fecha, [String locale = 'es']) {
    return DateFormat('d MMM yyyy', locale).format(fecha);
  }

  /// Formatea una fecha corta: "18/06/2026"
  static String formatearFechaCorta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  /// Formatea un rango de fechas: "18 jun. - 20 jun. 2026"
  static String formatearRango(DateTime inicio, DateTime fin,
      [String locale = 'es']) {
    if (inicio.year == fin.year && inicio.month == fin.month) {
      return '${DateFormat('d', locale).format(inicio)} - ${DateFormat('d MMM yyyy', locale).format(fin)}';
    }
    return '${formatearFecha(inicio, locale)} - ${formatearFecha(fin, locale)}';
  }

  /// Verifica si una fecha es hoy
  static bool esHoy(DateTime fecha) {
    final hoy = DateTime.now();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  /// Obtiene la fecha sin hora (solo año, mes, día)
  static DateTime soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  /// Formatea timestamp de Firestore a fecha legible
  static String formatearTimestamp(DateTime timestamp,
      [String locale = 'es']) {
    return DateFormat('d MMM yyyy, HH:mm', locale).format(timestamp);
  }
}
