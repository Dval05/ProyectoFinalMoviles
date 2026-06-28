import 'package:flutter/foundation.dart';

import '../../domain/entities/promocion.dart';
import '../../domain/usecases/promocion/actualizar_promocion_usecase.dart';
import '../../domain/usecases/promocion/crear_promocion_usecase.dart';
import '../../domain/usecases/promocion/get_promociones_usecase.dart';

class PromocionViewModel extends ChangeNotifier {
  PromocionViewModel({
    required this.getPromocionesUseCase,
    required this.crearPromocionUseCase,
    required this.actualizarPromocionUseCase,
  });

  final GetPromocionesUseCase getPromocionesUseCase;
  final CrearPromocionUseCase crearPromocionUseCase;
  final ActualizarPromocionUseCase actualizarPromocionUseCase;

  List<Promocion> _promociones = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Promocion> get promociones => _promociones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double obtenerDescuentoPara(String hosteriaId, String habitacionId) {
    if (_promociones.isEmpty) {
      return 0;
    }

    final ahora = DateTime.now();
    final activas = _promociones.where((p) {
      if (!p.activa) {
        return false;
      }
      if (ahora.isBefore(p.fechaInicio) || ahora.isAfter(p.fechaFin)) {
        return false;
      }

      if (p.hosteriaId != null && p.hosteriaId != hosteriaId) {
        return false;
      }
      if (p.habitacionId != null && p.habitacionId != habitacionId) {
        return false;
      }

      return true;
    }).toList();

    if (activas.isEmpty) return 0;

    double maxDesc = 0;
    for (final p in activas) {
      if (p.descuentoPorcentaje > maxDesc) {
        maxDesc = p.descuentoPorcentaje;
      }
    }
    return maxDesc;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> cargarPromociones() async {
    _setLoading(true);
    try {
      _promociones = await getPromocionesUseCase();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearPromocion({
    required String titulo,
    required String descripcion,
    required double descuentoPorcentaje,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? hosteriaId,
    String? habitacionId,
  }) async {
    _setLoading(true);
    try {
      final nueva = Promocion(
        id: '', // Firestore asignará el ID
        titulo: titulo,
        descripcion: descripcion,
        descuentoPorcentaje: descuentoPorcentaje,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        hosteriaId: hosteriaId,
        habitacionId: habitacionId,
        activa: true,
      );
      final promocionCreada = await crearPromocionUseCase(nueva);
      _promociones.add(promocionCreada);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> actualizarPromocion(Promocion promocion) async {
    _setLoading(true);
    try {
      await actualizarPromocionUseCase(promocion);
      final index = _promociones.indexWhere((p) => p.id == promocion.id);
      if (index != -1) {
        _promociones[index] = promocion;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
