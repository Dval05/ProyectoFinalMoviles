import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/widgets/gradient_button.dart';

void main() {
  testWidgets('GradientButton renders properly and handles taps', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GradientButton(
          text: 'Presionar',
          onPressed: () { tapped = true; },
        ),
      ),
    ));

    // Verifica el texto
    expect(find.text('Presionar'), findsOneWidget);

    // Simula el clic
    await tester.tap(find.byType(GradientButton));
    await tester.pumpAndSettle();

    // Verifica el callback
    expect(tapped, isTrue);
  });

  testWidgets('GradientButton shows loading indicator when isLoading is true', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GradientButton(
          text: 'Presionar',
          onPressed: () {},
          isLoading: true,
        ),
      ),
    ));

    // No debe mostrar el texto si está cargando (según el código de GradientButton)
    expect(find.text('Presionar'), findsNothing);
    // Debe mostrar CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
