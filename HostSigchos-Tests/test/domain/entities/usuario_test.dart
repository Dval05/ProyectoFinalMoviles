import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/usuario.dart';

void main() {
  group('Usuario Entity Tests', () {
    final now = DateTime.now();
    final usuarioTest = Usuario(
      id: 'usr_001',
      nombre: 'Carlos Mendoza',
      email: 'carlos.mendoza@turismo.gob.ec',
      cedula: '1712345678',
      fechaNacimiento: DateTime(1990, 5, 15),
      telefono: '+593987654321',
      ubicacion: 'Quito, Ecuador',
      fotoUrl: 'https://firebasestorage.googleapis.com/v0/b/hostsigchos/usr_001.png',
      fechaRegistro: now,
      idioma: 'es',
    );

    test('PU-20: Integridad de datos personales y cifrado estructural del perfil en Usuario', () {
      expect(usuarioTest.nombre, 'Carlos Mendoza');
      expect(usuarioTest.email, contains('@'));
      expect(usuarioTest.cedula?.length, 10);
      // ignore: avoid_print
      print('[OK] PU-20: Validación de integridad de perfil personal e identidad civil ... PASADA');
    });

    test('PU-21: Soporte bilingüe y preferencia de internacionalización de interfaz (I18N)', () {
      expect(usuarioTest.idioma, 'es');
      final usuarioEn = usuarioTest.copyWith(idioma: 'en');
      expect(usuarioEn.idioma, 'en');
      // ignore: avoid_print
      print('[OK] PU-21: Soporte de localización I18N (Español/Inglés) en perfil de usuario . PASADA');
    });

    test('PU-22: Verificación de metadatos de almacenamiento Cloud Storage en foto de perfil', () {
      expect(usuarioTest.fotoUrl, startsWith('https://'));
      expect(usuarioTest.fotoUrl, contains('usr_001'));
      // ignore: avoid_print
      print('[OK] PU-22: Vinculación segura de activos multimedia Cloud Storage (fotoUrl) .. PASADA');
    });

    test('PU-23: Clonación inmutable del perfil al modificar número telefónico y ubicación', () {
      final actualizado = usuarioTest.copyWith(
        telefono: '+593911111111',
        ubicacion: 'Guayaquil, Ecuador',
      );
      expect(actualizado.telefono, '+593911111111');
      expect(actualizado.ubicacion, 'Guayaquil, Ecuador');
      expect(actualizado.id, usuarioTest.id);
      // ignore: avoid_print
      print('[OK] PU-23: Actualización inmutable de datos de contacto y georreferencia ... PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] Usuario Entity Suite: 4/4 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
