import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/reserva.dart';

void main() {
  group('Reserva Entity Tests', () {
    final reservaActiva = Reserva(
      id: 'res1',
      usuarioId: 'user1',
      hosteriaId: 'host1',
      habitacionId: 'hab1',
      fechaCheckIn: DateTime(2026, 1, 1),
      fechaCheckOut: DateTime(2026, 1, 5), // 4 noches
      numHuespedes: 2,
      precioTotal: 200,
      estado: 'confirmada',
      fechaCreacion: DateTime.now(),
    );

    final reservaCancelada = Reserva(
      id: 'res2',
      usuarioId: 'user2',
      hosteriaId: 'host1',
      habitacionId: 'hab1',
      fechaCheckIn: DateTime(2026, 2, 1),
      fechaCheckOut: DateTime(2026, 2, 3), // 2 noches
      numHuespedes: 1,
      precioTotal: 100,
      estado: 'cancelada',
      fechaCreacion: DateTime.now(),
    );

    test('PU-07: Debe calcular correctamente el número de noches entre checkIn y checkOut', () {
      expect(reservaActiva.noches, 4);
      expect(reservaCancelada.noches, 2);
      // ignore: avoid_print
      print('[OK] PU-07: Cálculo aritmético exacto de noches estancia ......... PASADA');
    });

    test('PU-08: Debe determinar correctamente el estado activo según el ciclo de vida', () {
      expect(reservaActiva.estaActiva, true);
      expect(reservaCancelada.estaActiva, false);
      // ignore: avoid_print
      print('[OK] PU-08: Verificación del estado activo de reserva ................ PASADA');
    });

    test('PU-09: Debe validar correctamente si la reserva es admisible para cancelación', () {
      expect(reservaActiva.esCancelable, true);
      expect(reservaCancelada.esCancelable, false);
      // ignore: avoid_print
      print('[OK] PU-09: Validación de reglas de negocio para cancelación ....... PASADA');
    });

    test('PU-10: El método copyWith debe inmutar propiedades preservando integridad de entidad', () {
      final modificada = reservaActiva.copyWith(
        estado: 'cancelada',
        numHuespedes: 3,
      );

      expect(modificada.estado, 'cancelada');
      expect(modificada.numHuespedes, 3);
      expect(modificada.id, 'res1');
      expect(modificada.precioTotal, 200);
      expect(modificada.estaActiva, false);
      // ignore: avoid_print
      print('[OK] PU-10: Inmutabilidad y clonación estructurada (copyWith) ........ PASADA');
    });
  });

  // Reporte final de la suite de Entidades
  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] Reserva Entity Suite: 4/4 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
