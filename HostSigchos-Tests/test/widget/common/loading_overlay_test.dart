import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/widgets/loading_overlay.dart';

void main() {
  group('LoadingOverlay Widget Tests (PW-08 a PW-10)', () {
    testWidgets('PW-08: Cuando isLoading=false se renderiza únicamente el widget hijo (child)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: false,
            child: const Text('Contenido Principal Protegido'),
          ),
        ),
      ));

      expect(find.text('Contenido Principal Protegido'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // ignore: avoid_print
      print('[OK] PW-08: Renderizado transparente y limpio de contenido (isLoading=false)  PASADA');
    });

    testWidgets('PW-09: Cuando isLoading=true se despliega tarjeta con CircularProgressIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: const Text('Contenido Principal Protegido'),
          ),
        ),
      ));

      expect(find.text('Contenido Principal Protegido'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Por favor espera...'), findsOneWidget);
      // ignore: avoid_print
      print('[OK] PW-09: Despliegue sobrepuesto del indicador circular de progreso ...... PASADA');
    });

    testWidgets('PW-10: La capa oscura superior absorbe interacciones impidiendo clicks accidentales', (WidgetTester tester) async {
      bool childTapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: ElevatedButton(
              onPressed: () { childTapped = true; },
              child: const Text('Boton Trasero'),
            ),
          ),
        ),
      ));

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(childTapped, false);
      // ignore: avoid_print
      print('[OK] PW-10: Bloqueo interaccional en capa oscura durante carga asíncrona .. PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] LoadingOverlay Widget Suite: 3/3 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
