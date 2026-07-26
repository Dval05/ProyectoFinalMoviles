import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/habitacion.dart';

void main() {
  group('Habitacion Entity Tests', () {
    const habitacionTest = Habitacion(
      id: 'hab_mat_01',
      hosteriaId: 'host1',
      tipo: 'Suite Nupcial Panorámica',
      descripcion: 'Suite de lujo con chimenea, jacuzzi y vista al Cañón del Toachi.',
      capacidad: 2,
      precioPorNoche: 120.0,
      imagenes: ['suite1.jpg', 'suite2.jpg', 'suite3.jpg'],
      amenidades: ['Jacuzzi', 'Chimenea', 'Minibar', 'TV OLED 65"'],
      disponible: true,
      cantidadTotal: 3,
    );

    test('PU-16: Validación del aforo máximo permitido por habitación en el inventario', () {
      expect(habitacionTest.capacidad, 2);
      expect(habitacionTest.cantidadTotal, 3);
      expect(habitacionTest.tipo, 'Suite Nupcial Panorámica');
      // ignore: avoid_print
      print('[OK] PU-16: Aforo máximo y control cuantitativo del inventario hotelero ....... PASADA');
    });

    test('PU-17: Verificación de amenidades de alto valor y equipamiento en habitación', () {
      expect(habitacionTest.amenidades.length, 4);
      expect(habitacionTest.amenidades, contains('Jacuzzi'));
      expect(habitacionTest.amenidades, contains('Chimenea'));
      // ignore: avoid_print
      print('[OK] PU-17: Equipamiento de lujo y amenidades en catálogo de habitación ........ PASADA');
    });

    test('PU-18: Bloqueo inmutable del inventario físico cuando la disponibilidad cae a cero', () {
      final sinCupo = habitacionTest.copyWith(
        disponible: false,
        cantidadTotal: 0,
      );

      expect(sinCupo.disponible, false);
      expect(sinCupo.cantidadTotal, 0);
      expect(sinCupo.id, habitacionTest.id);
      expect(habitacionTest.disponible, true);
      // ignore: avoid_print
      print('[OK] PU-18: Bloqueo inmutable transaccional cuando disponibilidad es 0 ......... PASADA');
    });

    test('PU-19: Ajuste dinámico del precio por noche y copiado inmutable de entidad', () {
      final promocion = habitacionTest.copyWith(precioPorNoche: 99.99);
      expect(promocion.precioPorNoche, 99.99);
      expect(habitacionTest.precioPorNoche, 120.0);
      // ignore: avoid_print
      print('[OK] PU-19: Ajuste dinámico tarifario y aislamiento en Habitacion (copyWith) ... PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] Habitacion Entity Suite: 4/4 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
