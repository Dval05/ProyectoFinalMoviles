
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Prueba funcional: Arranque de la app y elementos básicos', (WidgetTester tester) async {
    debugPrint('[INFO] Iniciando prueba funcional en dispositivo físico Samsung');
    
    // Iniciar la aplicación
    app.main();
    
    // Esperar a que Firebase se inicialice y termine el Splash Screen.
    // Usamos pump manual porque pumpAndSettle() falla con animaciones infinitas como los Carruseles.
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    
    debugPrint('[INFO] Aplicación cargada exitosamente. Verificando elementos.');

    // Verificar existencia de MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    debugPrint('[OK] MaterialApp encontrado');

    // Verificar existencia de Scaffold
    expect(find.byType(Scaffold), findsWidgets);
    debugPrint('[OK] Scaffold(s) encontrados en la vista actual');

    // Verificar textos básicos renderizados
    expect(find.byType(Text), findsWidgets);
    debugPrint('[OK] Widgets de texto encontrados');

    // Pumping de frames adicionales para simular fluidez de UI y respuesta
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    debugPrint('[SUCCESS] La prueba funcional ha concluido sin errores');
  });
}
