import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/viewmodels/auth_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/habitacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/hosteria_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/locale_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/notificacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/reserva_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/weather_viewmodel.dart';
import 'package:mockito/annotations.dart';

// Generar mocks para inyectarlos en el MultiProvider
@GenerateNiceMocks([
  MockSpec<AuthViewModel>(),
  MockSpec<HosteriaViewModel>(),
  MockSpec<HabitacionViewModel>(),
  MockSpec<ReservaViewModel>(),
  MockSpec<LocaleViewModel>(),
  MockSpec<WeatherViewModel>(),
  MockSpec<NotificacionViewModel>(),
])

void main() {
  testWidgets('HomeScreen test boilerplate', (WidgetTester tester) async {
    expect(true, true);
  });
}
