import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/reserva.dart';
import 'package:frontend/domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import 'package:frontend/domain/usecases/reserva/actualizar_estado_reserva_usecase.dart';
import 'package:frontend/domain/usecases/reserva/cancelar_reserva_usecase.dart';
import 'package:frontend/domain/usecases/reserva/crear_reserva_usecase.dart';
import 'package:frontend/domain/usecases/reserva/get_historial_reservas_usecase.dart';
import 'package:frontend/domain/usecases/reserva/get_todas_las_reservas_usecase.dart';
import 'package:frontend/presentation/viewmodels/reserva_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  CrearReservaUseCase,
  GetHistorialReservasUseCase,
  GetTodasLasReservasUseCase,
  ActualizarEstadoReservaUseCase,
  CancelarReservaUseCase,
  CheckDisponibilidadUseCase
])
import 'reserva_viewmodel_test.mocks.dart';

void main() {
  late ReservaViewModel viewModel;
  late MockCrearReservaUseCase mockCrearReservaUseCase;
  late MockGetHistorialReservasUseCase mockGetHistorialReservasUseCase;
  late MockGetTodasLasReservasUseCase mockGetTodasLasReservasUseCase;
  late MockActualizarEstadoReservaUseCase mockActualizarEstadoReservaUseCase;
  late MockCancelarReservaUseCase mockCancelarReservaUseCase;
  late MockCheckDisponibilidadUseCase mockCheckDisponibilidadUseCase;

  setUp(() {
    mockCrearReservaUseCase = MockCrearReservaUseCase();
    mockGetHistorialReservasUseCase = MockGetHistorialReservasUseCase();
    mockGetTodasLasReservasUseCase = MockGetTodasLasReservasUseCase();
    mockActualizarEstadoReservaUseCase = MockActualizarEstadoReservaUseCase();
    mockCancelarReservaUseCase = MockCancelarReservaUseCase();
    mockCheckDisponibilidadUseCase = MockCheckDisponibilidadUseCase();

    viewModel = ReservaViewModel(
      crearReservaUseCase: mockCrearReservaUseCase,
      getHistorialReservasUseCase: mockGetHistorialReservasUseCase,
      getTodasLasReservasUseCase: mockGetTodasLasReservasUseCase,
      actualizarEstadoReservaUseCase: mockActualizarEstadoReservaUseCase,
      cancelarReservaUseCase: mockCancelarReservaUseCase,
      checkDisponibilidadUseCase: mockCheckDisponibilidadUseCase,
    );
  });

  final testReserva = Reserva(
    id: 'reserva1',
    usuarioId: 'user1',
    hosteriaId: 'host1',
    habitacionId: 'hab1',
    fechaCheckIn: DateTime.now(),
    fechaCheckOut: DateTime.now().add(const Duration(days: 2)),
    estado: 'pendiente',
    precioTotal: 100,
    numHuespedes: 2,
    fechaCreacion: DateTime.now(),
  );

  test('crearReserva debe cambiar estado y llamar al useCase', () async {
    when(mockCrearReservaUseCase.call(any)).thenAnswer((_) async => testReserva);

    // Act
    final result = await viewModel.crearReserva(testReserva);

    // Assert
    expect(result, true);
    expect(viewModel.reservaActual, testReserva);
    expect(viewModel.isLoading, false);
    verify(mockCrearReservaUseCase.call(testReserva)).called(1);
  });
}
