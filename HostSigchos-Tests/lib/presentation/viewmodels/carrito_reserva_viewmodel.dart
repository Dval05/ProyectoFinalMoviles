import 'package:flutter/foundation.dart';
import '../../domain/entities/habitacion.dart';

class ItemCarrito {
  ItemCarrito({
    required this.habitacion,
    required this.fechaCheckIn,
    required this.fechaCheckOut,
    required this.numHuespedes,
    required this.numHabitaciones,
    this.notas,
    this.esParaOtraPersona = false,
    this.nombreOtraPersona,
  });

  final Habitacion habitacion;
  final DateTime fechaCheckIn;
  final DateTime fechaCheckOut;
  final int numHuespedes;
  final int numHabitaciones;
  final String? notas;
  final bool esParaOtraPersona;
  final String? nombreOtraPersona;

  int get noches {
    final diff = fechaCheckOut.difference(fechaCheckIn).inDays;
    return diff == 0 ? 1 : diff;
  }

  double get precioTotal =>
      noches * habitacion.precioPorNoche * numHabitaciones;
}

class CarritoReservaViewModel extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  double get totalCarrito =>
      _items.fold(0, (sum, item) => sum + item.precioTotal);

  void agregarItem(ItemCarrito item) {
    _items.add(item);
    notifyListeners();
  }

  void eliminarItem(ItemCarrito item) {
    _items.remove(item);
    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}
