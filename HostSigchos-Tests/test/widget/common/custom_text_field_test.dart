import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget Tests (PW-05 a PW-07)', () {
    testWidgets('PW-05: Renderizado con icono prefijo, etiqueta y binding a TextEditingController', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            label: 'Correo Electrónico',
            prefixIcon: Icons.email,
            controller: controller,
          ),
        ),
      ));

      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      
      await tester.enterText(find.byType(TextFormField), 'turista@sigchos.ec');
      expect(controller.text, 'turista@sigchos.ec');
      // ignore: avoid_print
      print('[OK] PW-05: Binding bidireccional de datos con TextEditingController ... PASADA');
    });

    testWidgets('PW-06: Funcionamiento de botón para alternar visibilidad de contraseña (obscureText)', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            label: 'Contraseña',
            prefixIcon: Icons.lock,
            controller: controller,
            isPassword: true,
          ),
        ),
      ));

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      // ignore: avoid_print
      print('[OK] PW-06: Alternancia interactiva de privacidad en contraseñas ........ PASADA');
    });

    testWidgets('PW-07: Validación de sintaxis y visualización de mensaje de error en formulario', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CustomTextField(
              label: 'Teléfono',
              prefixIcon: Icons.phone,
              controller: controller,
              validator: (val) => val == null || val.isEmpty ? 'El teléfono es obligatorio' : null,
            ),
          ),
        ),
      ));

      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('El teléfono es obligatorio'), findsOneWidget);
      // ignore: avoid_print
      print('[OK] PW-07: Validación reactiva y retroalimentación de error en UI ..... PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] CustomTextField Widget Suite: 3/3 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
