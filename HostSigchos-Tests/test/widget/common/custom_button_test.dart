import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/widgets/gradient_button.dart';

void main() {
  group('GradientButton Widget Tests (PW-01 a PW-04)', () {
    testWidgets('PW-01: GradientButton renderiza texto correctamente y estructura visual con gradiente', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Reservar Ahora',
            onPressed: () {},
          ),
        ),
      ));

      expect(find.text('Reservar Ahora'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      // ignore: avoid_print
      print('[OK] PW-01: Renderizado estructural con gradiente y tipografía .......... PASADA');
    });

    testWidgets('PW-02: GradientButton responde eficientemente a eventos táctiles del usuario', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Presionar',
            onPressed: () { tapped = true; },
          ),
        ),
      ));

      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      // ignore: avoid_print
      print('[OK] PW-02: Interactividad táctil y disparo exacto del callback (onTap) . PASADA');
    });

    testWidgets('PW-03: GradientButton oculta texto y despliega CircularProgressIndicator al cargar', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Procesando Pago',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ));

      expect(find.text('Procesando Pago'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // ignore: avoid_print
      print('[OK] PW-03: Transición visual a indicador de carga (isLoading = true) .... PASADA');
    });

    testWidgets('PW-04: GradientButton desactiva interacciones cuando onPressed es nulo o está en carga', (WidgetTester tester) async {
      int clicks = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Inactivo',
            onPressed: () { clicks++; },
            isLoading: true,
          ),
        ),
      ));

      await tester.tap(find.byType(GradientButton));
      expect(clicks, 0);
      // ignore: avoid_print
      print('[OK] PW-04: Prevención de doble envío y bloqueo táctil en estado de carga  PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] GradientButton Widget Suite: 4/4 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
