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

    test('Debe calcular correctamente el número de noches', () {
      expect(reservaActiva.noches, 4);
      expect(reservaCancelada.noches, 2);
    });

    test('Debe determinar si la reserva está activa', () {
      expect(reservaActiva.estaActiva, true);
      expect(reservaCancelada.estaActiva, false);
    });

    test('Debe determinar si la reserva es cancelable', () {
      expect(reservaActiva.esCancelable, true);
      expect(reservaCancelada.esCancelable, false);
    });

    test('El método copyWith debe actualizar las propiedades correctamente', () {
      final modificada = reservaActiva.copyWith(
        estado: 'cancelada',
        numHuespedes: 3,
      );

      expect(modificada.estado, 'cancelada');
      expect(modificada.numHuespedes, 3);
      // Las demás propiedades se mantienen igual
      expect(modificada.id, 'res1');
      expect(modificada.precioTotal, 200);
      expect(modificada.estaActiva, false); // Cambio de estado afecta getter
    });
  });
}
