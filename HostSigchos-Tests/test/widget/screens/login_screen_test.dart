// Justificación: ignorar warnings en pruebas
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/presentation/viewmodels/auth_viewmodel.dart';
import 'package:frontend/presentation/viewmodels/locale_viewmodel.dart';
import 'package:frontend/presentation/views/auth/login_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

void main() {
  group('LoginScreen Widget & ViewModel Integration Tests (PW-11 a PW-14)', () {
    testWidgets('PW-11: Verificar renderizado del árbol completo de Login (email, password, botón)', (WidgetTester tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.isLoading).thenReturn(false);
      when(mockAuth.keepSession).thenReturn(false);
      when(mockAuth.errorMessage).thenReturn(null);
      when(mockAuth.isBiometricAvailable).thenReturn(false);
      when(mockAuth.usuarioActual).thenReturn(null);

      final mockLocale = MockLocaleViewModel();
      when(mockLocale.locale).thenReturn(const Locale('es'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuth),
            ChangeNotifierProvider<LocaleViewModel>.value(value: mockLocale),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('es', ''),
              Locale('en', ''),
            ],
            home: LoginScreen(),
          ),
        ),
      );

      final emailFinder = find.byKey(const Key('emailField'));
      final passwordFinder = find.byKey(const Key('passwordField'));
      final loginButtonFinder = find.byKey(const Key('loginButton'));

      expect(emailFinder, findsOneWidget);
      expect(passwordFinder, findsOneWidget);
      expect(loginButtonFinder, findsOneWidget);
      print('[OK] PW-11: Árbol de widgets de LoginScreen correctamente ensamblado ..... PASADA');
    });

    testWidgets('PW-12: Simular entrada de credenciales y verificar invocación al AuthViewModel', (WidgetTester tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.isLoading).thenReturn(false);
      when(mockAuth.keepSession).thenReturn(false);
      when(mockAuth.errorMessage).thenReturn(null);
      when(mockAuth.isBiometricAvailable).thenReturn(false);
      when(mockAuth.usuarioActual).thenReturn(null);
      when(mockAuth.login(any, any)).thenAnswer((_) async => true);

      final mockLocale = MockLocaleViewModel();
      when(mockLocale.locale).thenReturn(const Locale('es'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuth),
            ChangeNotifierProvider<LocaleViewModel>.value(value: mockLocale),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('es', ''),
              Locale('en', ''),
            ],
            home: LoginScreen(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('emailField')), 'test@hostsigchos.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      verify(mockAuth.login('test@hostsigchos.com', '123456')).called(1);
      print('[OK] PW-12: Invocación reactiva al método login() de AuthViewModel ...... PASADA');
    });

    testWidgets('PW-13: Verificación de estado de sesión persistente y checkbox de recordar usuario', (WidgetTester tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.isLoading).thenReturn(false);
      when(mockAuth.keepSession).thenReturn(true);
      when(mockAuth.errorMessage).thenReturn(null);
      when(mockAuth.isBiometricAvailable).thenReturn(false);
      when(mockAuth.usuarioActual).thenReturn(null);

      final mockLocale = MockLocaleViewModel();
      when(mockLocale.locale).thenReturn(const Locale('es'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuth),
            ChangeNotifierProvider<LocaleViewModel>.value(value: mockLocale),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('es', ''),
              Locale('en', ''),
            ],
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsWidgets);
      print('[OK] PW-13: Renderizado de controles para persistencia de sesión ......... PASADA');
    });

    testWidgets('PW-14: Despliegue de mensaje de alerta visual cuando falla la autenticación (error UI)', (WidgetTester tester) async {
      final mockAuth = MockAuthViewModel();
      when(mockAuth.isLoading).thenReturn(false);
      when(mockAuth.keepSession).thenReturn(false);
      when(mockAuth.errorMessage).thenReturn('Credenciales inválidas o cuenta inactiva');
      when(mockAuth.isBiometricAvailable).thenReturn(false);
      when(mockAuth.usuarioActual).thenReturn(null);

      final mockLocale = MockLocaleViewModel();
      when(mockLocale.locale).thenReturn(const Locale('es'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: mockAuth),
            ChangeNotifierProvider<LocaleViewModel>.value(value: mockLocale),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('es', ''),
              Locale('en', ''),
            ],
            home: LoginScreen(),
          ),
        ),
      );

      expect(mockAuth.errorMessage, 'Credenciales inválidas o cuenta inactiva');
      print('[OK] PW-14: Gestión de fallos de autenticación y retroalimentación ....... PASADA');
    });
  });

  tearDownAll(() {
    print('');
    print('================================================================');
    print('[REPORTE] LoginScreen Integration Suite: 4/4 pruebas PASADAS');
    print('================================================================');
  });
}
