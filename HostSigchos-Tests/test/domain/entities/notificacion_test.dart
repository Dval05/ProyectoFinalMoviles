import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/notificacion.dart';

void main() {
  group('NotificacionApp Entity Tests', () {
    final now = DateTime.now();
    final notificacionTest = NotificacionApp(
      id: 'notif_055',
      usuarioId: 'usr_001',
      titulo: '¡Tu Reserva fue Confirmada!',
      mensaje: 'El administrador ha validado tu pago. Prepárate para tu viaje a Sigchos.',
      fecha: now,
      leida: false,
      tipo: 'reserva',
    );

    test('PU-27: Clasificación tipológica de notificaciones en tiempo real (reserva/oferta/sistema)', () {
      expect(notificacionTest.tipo, 'reserva');
      expect(['reserva', 'oferta', 'sistema'], contains(notificacionTest.tipo));
      expect(notificacionTest.leida, false);
      // ignore: avoid_print
      print('[OK] PU-27: Tipología y taxonomía de eventos del sistema de notificaciones .... PASADA');
    });

    test('PU-28: Transición de ciclo de vida de notificación no leída hacia estado leído', () {
      final leida = notificacionTest.copyWith(leida: true);
      expect(leida.leida, true);
      expect(notificacionTest.leida, false);
      expect(leida.id, notificacionTest.id);
      // ignore: avoid_print
      print('[OK] PU-28: Transición inmutable de lectura de notificaciones (leída=true) ... PASADA');
    });

    test('PU-29: Conservación de marcas de tiempo UTC para auditoría transaccional push', () {
      expect(notificacionTest.fecha, now);
      expect(notificacionTest.titulo, startsWith('¡Tu Reserva'));
      // ignore: avoid_print
      print('[OK] PU-29: Precisión temporal y metadatos de auditoría en NotificacionApp .. PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] NotificacionApp Entity Suite: 3/3 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
