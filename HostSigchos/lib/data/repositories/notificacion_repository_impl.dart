import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificacion_repository.dart';
import '../datasources/firebase/notificacion_datasource.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  NotificacionRepositoryImpl(this._dataSource);

  final NotificacionDataSource _dataSource;

  @override
  Stream<List<NotificacionApp>> getNotificacionesStream(String usuarioId) {
    return _dataSource.getNotificacionesStream(usuarioId);
  }

  @override
  Future<void> marcarLeida(String id) {
    return _dataSource.marcarLeida(id);
  }

  @override
  Future<void> marcarTodasComoLeidas(String usuarioId) {
    return _dataSource.marcarTodasComoLeidas(usuarioId);
  }

  @override
  Future<void> borrarTodas(String usuarioId) {
    return _dataSource.borrarTodas(usuarioId);
  }
}
