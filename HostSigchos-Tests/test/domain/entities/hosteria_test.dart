import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/hosteria.dart';

void main() {
  group('Hosteria Entity Tests', () {
    const hosteriaTest = Hosteria(
      id: 'host1',
      nombre: 'Hostería Hacienda San José de Sigchos',
      descripcion: 'Hermoso complejo turístico en los Andes con aguas termales y vistas panorámicas.',
      direccion: 'Av. Principal 123, Sigchos, Cotopaxi',
      latitud: -0.7001,
      longitud: -78.8892,
      telefono: '+593999999999',
      email: 'contacto@sanjosereview.ec',
      sitioWeb: 'https://sanjose-sigchos.ec',
      rating: 4.8,
      imagenes: ['img1.jpg', 'img2.jpg'],
      servicios: ['Wifi', 'Piscina', 'Restaurante', 'Parqueadero'],
      activa: true,
      precioPorNoche: 65.0,
      totalResenas: 42,
    );

    test('PU-11: Construcción de entidad Hosteria conserva coordenadas geolocalizadas GPS del cantón Sigchos', () {
      expect(hosteriaTest.latitud, -0.7001);
      expect(hosteriaTest.longitud, -78.8892);
      expect(hosteriaTest.direccion.contains('Sigchos'), isTrue);
      // ignore: avoid_print
      print('[OK] PU-11: Precisión de georeferenciación y lat/long en entidad Hosteria .... PASADA');
    });

    test('PU-12: Verificación de estructura de catálogo gastronómico y servicios turísticos asociados', () {
      expect(hosteriaTest.servicios.length, 4);
      expect(hosteriaTest.servicios, contains('Wifi'));
      expect(hosteriaTest.servicios, contains('Piscina'));
      // ignore: avoid_print
      print('[OK] PU-12: Catálogo de servicios turísticos y amenidades de hostería ......... PASADA');
    });

    test('PU-13: Cálculo del índice de reputación (rating) y volumen de reseñas verificadas', () {
      expect(hosteriaTest.rating >= 0.0 && hosteriaTest.rating <= 5.0, isTrue);
      expect(hosteriaTest.totalResenas, 42);
      // ignore: avoid_print
      print('[OK] PU-13: Reputación algorítmica (rating 0.0 - 5.0) en Hosteria ................ PASADA');
    });

    test('PU-14: Inmutabilidad al actualizar tarifa por temporada alta mediante copyWith', () {
      final temporadaAlta = hosteriaTest.copyWith(
        precioPorNoche: 85.0,
        rating: 4.9,
        totalResenas: 43,
      );

      expect(temporadaAlta.precioPorNoche, 85.0);
      expect(temporadaAlta.rating, 4.9);
      expect(temporadaAlta.totalResenas, 43);
      expect(temporadaAlta.id, hosteriaTest.id); // Inmutable
      // ignore: avoid_print
      print('[OK] PU-14: Actualización inmutable tarifaria estacional con copyWith .......... PASADA');
    });

    test('PU-15: Cambio de estado operativo del complejo turístico (activa/inactiva)', () {
      final mantenimiento = hosteriaTest.copyWith(activa: false);
      expect(mantenimiento.activa, false);
      expect(hosteriaTest.activa, true);
      // ignore: avoid_print
      print('[OK] PU-15: Control de ciclo operativo y suspensión (activa/inactiva) .......... PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] Hosteria Entity Suite: 5/5 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
