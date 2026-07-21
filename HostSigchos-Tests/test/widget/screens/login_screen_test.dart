// Justificación: ignorar warnings en pruebas
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
  testWidgets('LoginScreen interactúa con AuthViewModel', (WidgetTester tester) async {
    final mockAuth = MockAuthViewModel();
    
    // El viewmodel arranca sin cargar
    when(mockAuth.isLoading).thenReturn(false);
    when(mockAuth.keepSession).thenReturn(false);
    when(mockAuth.errorMessage).thenReturn(null);
    when(mockAuth.isBiometricAvailable).thenReturn(false);
    when(mockAuth.usuarioActual).thenReturn(null);
    
    // Stub para el login
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

    // Encuentra los campos reales usando las llaves
    final emailFinder = find.byKey(const Key('emailField'));
    final passwordFinder = find.byKey(const Key('passwordField'));
    final loginButtonFinder = find.byKey(const Key('loginButton'));

    expect(emailFinder, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);

    // Ingresar credenciales
    await tester.enterText(emailFinder, 'test@hostsigchos.com');
    await tester.enterText(passwordFinder, '123456');
    
    // Tap botón de login
    await tester.tap(loginButtonFinder);
    
    // Permitir animaciones y rebuilds
    await tester.pumpAndSettle();

    // Verifica que se llamó el login del viewModel
    verify(mockAuth.login('test@hostsigchos.com', '123456')).called(1);
  });
}
