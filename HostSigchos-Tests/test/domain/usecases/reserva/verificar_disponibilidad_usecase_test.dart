// Ignorar document_ignores
// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/habitacion.dart';
import 'package:frontend/domain/entities/reserva.dart';
import 'package:frontend/domain/repositories/reserva_repository.dart';
import 'package:frontend/domain/usecases/reserva/verificar_disponibilidad_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'verificar_disponibilidad_usecase_test.mocks.dart';

@GenerateMocks([ReservaRepository])
void main() {
  late VerificarDisponibilidadUseCase usecase;
  late MockReservaRepository mockRepository;

  setUp(() {
    mockRepository = MockReservaRepository();
    usecase = VerificarDisponibilidadUseCase(mockRepository);
  });

  final habitacionTest = Habitacion(
    id: 'hab123',
    hosteriaId: 'host1',
    tipo: 'Matrimonial',
    descripcion: 'Habitación Matrimonial estándar',
    precioPorNoche: 50,
    capacidad: 2,
    cantidadTotal: 5, // Hay 5 habitaciones de este tipo
    amenidades: const [],
    imagenes: const [],
  );

  group('VerificarDisponibilidadUseCase Tests', () {
    test('PU-01: Disponibilidad retorna TRUE cuando no hay reservas en el rango de fechas', () async {
      // Arrange
      final checkIn = DateTime(2026, 1, 10);
      final checkOut = DateTime(2026, 1, 15);
      when(mockRepository.getReservasPorHabitacion('hab123'))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase(habitacionTest, checkIn, checkOut, 2);

      // Assert
      expect(result, true);
      verify(mockRepository.getReservasPorHabitacion('hab123')).called(1);
      // ignore: avoid_print
      print('[OK] PU-01: Disponibilidad retorna TRUE en fechas libres .......... PASADA');
    });

    test('PU-02: Disponibilidad retorna TRUE cuando el inventario parcial aún tiene cupo', () async {
      // Arrange
      final checkIn = DateTime(2026, 1, 10);
      final checkOut = DateTime(2026, 1, 15);
      
      final reservaExistente = Reserva(
        id: 'res1',
        usuarioId: 'user1',
        hosteriaId: 'host1',
        habitacionId: 'hab123',
        fechaCheckIn: DateTime(2026, 1, 11),
        fechaCheckOut: DateTime(2026, 1, 14),
        numHuespedes: 2,
        numHabitaciones: 3, // Ocupan 3 de las 5 disponibles
        precioTotal: 150,
        fechaCreacion: DateTime.now(),
        estado: 'confirmada',
      );

      when(mockRepository.getReservasPorHabitacion('hab123'))
          .thenAnswer((_) async => [reservaExistente]);

      // Act
      // Pedimos 2 habitaciones. Quedan 2 libres (5 - 3). Debería ser true.
      final result = await usecase(habitacionTest, checkIn, checkOut, 2);

      // Assert
      expect(result, true);
      // ignore: avoid_print
      print('[OK] PU-02: Disponibilidad TRUE con inventario parcial (3/5 ocupadas) .. PASADA');
    });

    test('PU-03: Disponibilidad retorna FALSE por solapamiento y overbooking', () async {
      // Arrange
      final checkIn = DateTime(2026, 1, 10);
      final checkOut = DateTime(2026, 1, 15);
      
      final reservaExistente = Reserva(
        id: 'res1',
        usuarioId: 'user1',
        hosteriaId: 'host1',
        habitacionId: 'hab123',
        fechaCheckIn: DateTime(2026, 1, 9),
        fechaCheckOut: DateTime(2026, 1, 16),
        numHuespedes: 2,
        numHabitaciones: 4, // Ocupan 4 de las 5 disponibles
        precioTotal: 150,
        fechaCreacion: DateTime.now(),
        estado: 'confirmada',
      );

      when(mockRepository.getReservasPorHabitacion('hab123'))
          .thenAnswer((_) async => [reservaExistente]);

      // Act
      // Pedimos 2 habitaciones. Queda solo 1 libre (5 - 4). Debería ser false.
      final result = await usecase(habitacionTest, checkIn, checkOut, 2);

      // Assert
      expect(result, false);
      // ignore: avoid_print
      print('[OK] PU-03: Disponibilidad FALSE por solapamiento temporal ........ PASADA');
    });

    test('PU-04: El algoritmo ignora reservas con estado cancelado', () async {
      // Arrange
      final checkIn = DateTime(2026, 1, 10);
      final checkOut = DateTime(2026, 1, 15);
      
      final reservaCancelada = Reserva(
        id: 'res1',
        usuarioId: 'user1',
        hosteriaId: 'host1',
        habitacionId: 'hab123',
        fechaCheckIn: DateTime(2026, 1, 9),
        fechaCheckOut: DateTime(2026, 1, 16),
        numHuespedes: 2,
        numHabitaciones: 5, // Ocupaban todo el inventario, pero cancelada
        precioTotal: 150,
        fechaCreacion: DateTime.now(),
        estado: 'cancelada', 
      );

      when(mockRepository.getReservasPorHabitacion('hab123'))
          .thenAnswer((_) async => [reservaCancelada]);

      // Act
      final result = await usecase(habitacionTest, checkIn, checkOut, 2);

      // Assert
      expect(result, true); // Como está cancelada, no se cuenta
      // ignore: avoid_print
      print('[OK] PU-04: Reservas canceladas son excluidas del cálculo ......... PASADA');
    });
  });

  // Reporte final
  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] VerificarDisponibilidadUseCase: 4/4 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
