import '../entities/notificacion.dart';

abstract class NotificacionRepository {
  Stream<List<NotificacionApp>> getNotificacionesStream(String usuarioId);
  Future<void> marcarLeida(String id);
  Future<void> marcarTodasComoLeidas(String usuarioId);
  Future<void> borrarTodas(String usuarioId);
}
