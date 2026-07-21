import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificacion_repository.dart';

class NotificacionViewModel extends ChangeNotifier {
  NotificacionViewModel(this._repository);

  final NotificacionRepository _repository;
  
  List<NotificacionApp> _notificaciones = [];
  List<NotificacionApp> get notificaciones => _notificaciones;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<List<NotificacionApp>>? _subscription;

  void listenToNotificaciones(String usuarioId) {
    if (usuarioId.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.getNotificacionesStream(usuarioId).listen((data) {
      _notificaciones = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> marcarLeida(String id) async {
    try {
      await _repository.marcarLeida(id);
    } catch (e) {
      debugPrint('Error al marcar leída: $e');
    }
  }

  Future<void> marcarTodasComoLeidas(String usuarioId) async {
    try {
      await _repository.marcarTodasComoLeidas(usuarioId);
    } catch (e) {
      debugPrint('Error al marcar todas como leídas: $e');
    }
  }

  Future<void> borrarTodas(String usuarioId) async {
    try {
      await _repository.borrarTodas(usuarioId);
    } catch (e) {
      debugPrint('Error al borrar todas las notificaciones: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
