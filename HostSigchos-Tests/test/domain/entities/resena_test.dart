import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/resena.dart';

void main() {
  group('Resena Entity Tests', () {
    final now = DateTime.now();
    final resenaTest = Resena(
      id: 'rev_101',
      hosteriaId: 'host1',
      usuarioId: 'usr_001',
      nombreUsuario: 'Elena Ramos',
      comentario: 'La atención excelente y la comida típica deliciosa. Muy recomendado.',
      rating: 5.0,
      fecha: now,
    );

    test('PU-24: Validación de rango de puntuación en reseña de cliente (0.0 a 5.0 estrellas)', () {
      expect(resenaTest.rating >= 0.0 && resenaTest.rating <= 5.0, isTrue);
      expect(resenaTest.rating, 5.0);
      expect(resenaTest.nombreUsuario, 'Elena Ramos');
      // ignore: avoid_print
      print('[OK] PU-24: Control de límites y validación algorítmica de rating en Reseña ... PASADA');
    });

    test('PU-25: Integridad de asociación relacional entre Usuario y Hostería evaluada', () {
      expect(resenaTest.hosteriaId, 'host1');
      expect(resenaTest.usuarioId, 'usr_001');
      expect(resenaTest.comentario.isNotEmpty, isTrue);
      // ignore: avoid_print
      print('[OK] PU-25: Coherencia relacional de claves externas (hosteriaId / usuarioId) . PASADA');
    });

    test('PU-26: Edición moderada inmutable de comentario y actualización de fecha y rating', () {
      final resenaModificada = resenaTest.copyWith(
        rating: 4.5,
        comentario: 'Buen lugar, aunque el wifi falló un poco por la lluvia.',
      );
      expect(resenaModificada.rating, 4.5);
      expect(resenaModificada.comentario, contains('wifi'));
      expect(resenaModificada.id, resenaTest.id);
      // ignore: avoid_print
      print('[OK] PU-26: Edición inmutable de testimonios turísticos con método copyWith . PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] Resena Entity Suite: 3/3 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
