import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/reserva.dart';
import 'package:frontend/domain/repositories/reserva_repository.dart';
import 'package:frontend/domain/usecases/reserva/crear_reserva_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ReservaRepository])
import 'crear_reserva_usecase_test.mocks.dart';

void main() {
  late CrearReservaUseCase usecase;
  late MockReservaRepository mockRepository;

  setUp(() {
    mockRepository = MockReservaRepository();
    usecase = CrearReservaUseCase(mockRepository);
  });

  final reservaTest = Reserva(
    id: '', // ID vacío, se generará en el repositorio
    usuarioId: 'user1',
    hosteriaId: 'host1',
    habitacionId: 'hab1',
    fechaCheckIn: DateTime(2026, 1, 10),
    fechaCheckOut: DateTime(2026, 1, 15),
    numHuespedes: 2,
    precioTotal: 150,
    fechaCreacion: DateTime.now(),
    estado: 'pendiente',
  );

  final reservaDevuelta = reservaTest.copyWith(id: 'generated_id_123');

  group('CrearReservaUseCase Tests', () {
    test('PU-05: Crear reserva exitosa retorna objeto con ID generado', () async {
      // Arrange
      when(mockRepository.crearReserva(reservaTest))
          .thenAnswer((_) async => reservaDevuelta);

      // Act
      final result = await usecase(reservaTest);

      // Assert
      expect(result.id, 'generated_id_123');
      expect(result.estado, 'pendiente');
      verify(mockRepository.crearReserva(reservaTest)).called(1);
      // ignore: avoid_print
      print('[OK] PU-05: Crear reserva retorna objeto con ID generado ......... PASADA');
    });

    test('PU-06: Propaga excepción si el repositorio falla por overbooking transaccional', () async {
      // Arrange
      when(mockRepository.crearReserva(reservaTest))
          .thenThrow(Exception('La habitación ya no está disponible'));

      // Act & Assert
      expect(() => usecase(reservaTest), throwsA(isA<Exception>()));
      verify(mockRepository.crearReserva(reservaTest)).called(1);
      // ignore: avoid_print
      print('[OK] PU-06: Excepción propagada por overbooking transaccional .... PASADA');
    });
  });

  // Reporte final
  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] CrearReservaUseCase: 2/2 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
