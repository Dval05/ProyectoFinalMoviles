import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../presentation/routes/app_routes.dart';

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
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'reserva_exitosa') {
          AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.historialReservas);
        }
      },
    );

    // Solicitar permisos de notificación (necesario para Android 13+ y iOS)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
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
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final hosteria = nombreHosteria ?? 'la hostería';

    await _plugin.show(
      id: reservaId.hashCode,
      title: '¡Confirmación pendiente!',
      body: '¡Recuerda contactarte por WhatsApp para confirmar tu reserva en $hosteria!',
      notificationDetails: details,
      payload: 'reserva_exitosa', // Reutilizamos el mismo payload para ir al historial
    );
  }

  /// Muestra una notificación cuando se crea la reserva exitosamente
  Future<void> mostrarNotificacionReservaExitosa() async {
    if (!_initialized) await inicializar();

    const androidDetails = AndroidNotificationDetails(
      'reserva_exitosa_channel',
      'Reservas Exitosas',
      channelDescription: 'Notificaciones cuando se confirma una reserva',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '¡Reserva Exitosa!',
      body: 'Tu reserva ha sido registrada correctamente. Toca aquí para ver tu reserva.',
      notificationDetails: details,
      payload: 'reserva_exitosa',
    );
  }

  /// Muestra una notificación local genérica (pop-up de sistema)
  Future<void> mostrarNotificacionLocal({
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    if (!_initialized) await inicializar();

    const androidDetails = AndroidNotificationDetails(
      'alertas_generales_channel',
      'Alertas Generales',
      channelDescription: 'Notificaciones sobre la actividad del usuario',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: titulo,
      body: cuerpo,
      notificationDetails: details,
      payload: payload,
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
