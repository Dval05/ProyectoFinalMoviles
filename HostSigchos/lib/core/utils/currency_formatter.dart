import 'package:intl/intl.dart';

/// Formato de moneda para precios en USD
class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  /// Formatea un precio: 87.0 → "$87.00"
  static String formatear(double monto) {
    return _formatter.format(monto);
  }

  /// Formatea un precio con etiqueta: "$87.00 / noche"
  static String porNoche(double monto) {
    return '${formatear(monto)} / noche';
  }

  /// Formatea precio total con noches: "$174.00 (2 noches)"
  static String conNoches(double montoTotal, int noches) {
    return '${formatear(montoTotal)} ($noches ${noches == 1 ? 'noche' : 'noches'})';
  }
}
