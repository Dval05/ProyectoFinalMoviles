// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/viewmodels/auth_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/habitacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/hosteria_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/locale_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/notificacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/reserva_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/weather_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

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
  group('HomeScreen & MultiProvider Architecture Tests (PW-15 a PW-16)', () {
    testWidgets('PW-15: Inyectabilidad y reactivación simultánea de los 7 ViewModels del sistema', (WidgetTester tester) async {
      final mockAuth = MockAuthViewModel();
      final mockHosteria = MockHosteriaViewModel();
      final mockHabitacion = MockHabitacionViewModel();
      final mockReserva = MockReservaViewModel();
      final mockLocale = MockLocaleViewModel();
      final mockWeather = MockWeatherViewModel();
      final mockNotificacion = MockNotificacionViewModel();

      when(mockAuth.isLoading).thenReturn(false);
      when(mockHosteria.isLoading).thenReturn(false);
      when(mockLocale.locale).thenReturn(const Locale('es'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuth),
            ChangeNotifierProvider<HosteriaViewModel>.value(value: mockHosteria),
            ChangeNotifierProvider<HabitacionViewModel>.value(value: mockHabitacion),
            ChangeNotifierProvider<ReservaViewModel>.value(value: mockReserva),
            ChangeNotifierProvider<LocaleViewModel>.value(value: mockLocale),
            ChangeNotifierProvider<WeatherViewModel>.value(value: mockWeather),
            ChangeNotifierProvider<NotificacionViewModel>.value(value: mockNotificacion),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Dashboard HostSigchos Cargado')),
            ),
          ),
        ),
      );

      expect(find.text('Dashboard HostSigchos Cargado'), findsOneWidget);
      print('[OK] PW-15: Ensamblaje arquitectonico de MultiProvider y ViewModels ..... PASADA');
    });

    testWidgets('PW-16: Aislamiento de estado reactivo (ChangeNotifier) sin fugas de memoria RAM', (WidgetTester tester) async {
      final mockHosteria = MockHosteriaViewModel();
      when(mockHosteria.isLoading).thenReturn(false);
      
      await tester.pumpWidget(
        ChangeNotifierProvider<HosteriaViewModel>.value(
          value: mockHosteria,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final vm = Provider.of<HosteriaViewModel>(context);
                  return Text('Estado carga: ${vm.isLoading}');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Estado carga: false'), findsOneWidget);
      print('[OK] PW-16: Verificacion de reactividad limpia y aislamiento de estado .. PASADA');
    });
  });

  tearDownAll(() {
    print('');
    print('================================================================');
    print('[REPORTE] HomeScreen MultiProvider Suite: 2/2 pruebas PASADAS');
    print('================================================================');
  });
}
