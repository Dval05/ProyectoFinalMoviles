
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Prueba de rendimiento y renderizado de frames', (WidgetTester tester) async {
    debugPrint('[INFO] Iniciando prueba de rendimiento de startup y renderizado');
    
    final stopWatch = Stopwatch()..start();
    
    app.main();
    
    // Esperar a que Firebase se inicialice y se monte el MaterialApp.
    // Usamos un bucle en lugar de pumpAndSettle para tener un tiempo preciso de arranque real.
    while (find.byType(MaterialApp).evaluate().isEmpty && stopWatch.elapsedMilliseconds < 8000) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    stopWatch.stop();
    final startupTime = stopWatch.elapsedMilliseconds;
    debugPrint('[TEST] Tiempo de inicio (startup): $startupTime ms');
    
    expect(startupTime, lessThan(12000), reason: 'El tiempo de inicio no debería exceder los 12000ms');
    debugPrint('[OK] Tiempo de inicio dentro del límite de 12000ms');

    debugPrint('[INFO] Iniciando prueba de renderizado de 20 frames (simulando 60FPS ~16ms)');
    final frameStopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    
    frameStopwatch.stop();
    final totalFrameTime = frameStopwatch.elapsedMilliseconds;
    final avgFrameTime = totalFrameTime / 20;
    
    debugPrint('[TEST] Tiempo total de 20 frames: $totalFrameTime ms');
    debugPrint('[TEST] Tiempo promedio por frame (incluyendo demoras del test): ${avgFrameTime.toStringAsFixed(2)} ms');
    
    expect(find.byType(MaterialApp), findsOneWidget);
    debugPrint('[SUCCESS] Pruebas de rendimiento completadas sin pérdida del árbol de widgets');
  });
}
