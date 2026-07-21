import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/viewmodels/auth_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/habitacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/hosteria_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/reserva_viewmodel.dart';
import 'package:frontend/presentation/views/home/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/presentation/viewmodels/locale_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/notificacion_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/weather_viewmodel.dart';

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
import 'home_screen_test.mocks.dart';

void main() {
  testWidgets('HomeScreen test boilerplate', (WidgetTester tester) async {
    expect(true, true);
  });
}
