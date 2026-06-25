import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio singleton para manejar notificaciones locales
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inicializa el servicio de notificaciones
  Future<void> inicializar() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  /// Muestra una notificación inmediata de pago pendiente
  Future<void> mostrarNotificacionPagoPendiente({
    required String reservaId,
    String? nombreHosteria,
  }) async {
    if (!_initialized) await inicializar();

    const androidDetails = AndroidNotificationDetails(
      'pago_pendiente_channel',
      'Pagos Pendientes',
      channelDescription: 'Notificaciones de recordatorio de pagos pendientes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final hosteria = nombreHosteria ?? 'la hostería';

    await _plugin.show(
      id: reservaId.hashCode,
      title: '¡Pago pendiente!',
      body: '¡Falta realizar tu pago para confirmar tu reserva en $hosteria!',
      notificationDetails: details,
    );
  }

  /// Programa una notificación diferida de pago pendiente
  Future<void> programarNotificacionPagoPendiente({
    required String reservaId,
    String? nombreHosteria,
    Duration delay = const Duration(hours: 1),
  }) async {
    if (!_initialized) await inicializar();

    // Usamos un Future.delayed para programar la notificación
    Future.delayed(delay, () {
      mostrarNotificacionPagoPendiente(
        reservaId: reservaId,
        nombreHosteria: nombreHosteria,
      );
    });

    debugPrint(
      'Notificación programada para ${delay.inMinutes} minutos - Reserva: $reservaId',
    );
  }

  /// Verifica reservas pendientes y envía notificaciones
  Future<void> verificarYNotificarPagosPendientes({
    required List<Map<String, String>> reservasPendientes,
  }) async {
    for (final reserva in reservasPendientes) {
      await mostrarNotificacionPagoPendiente(
        reservaId: reserva['id'] ?? '',
        nombreHosteria: reserva['nombreHosteria'],
      );
    }
  }
}
