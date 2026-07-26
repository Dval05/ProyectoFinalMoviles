
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/injection_container.dart';
import 'package:frontend/main.dart' as app;
import 'package:frontend/presentation/viewmodels/chatbot_viewmodel.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Prueba de resiliencia: Rate Limiting en Chatbot', (WidgetTester tester) async {
    debugPrint('[INFO] Iniciando prueba de Rate Limit (Ráfaga de mensajes)');
    
    try {
      app.main();
      
      // Esperar activamente a que Firebase se inicialice y GetIt se registre.
      // pumpAndSettle falla y no espera porque la UI está vacía mientras Firebase arranca.
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      
      debugPrint('[INFO] Aplicación iniciada, obteniendo ChatbotViewModel');
      
      final chatbotVm = getIt<ChatbotViewModel>();
      final stopwatch = Stopwatch();
      
      for (int i = 1; i <= 6; i++) {
        debugPrint('[TEST] Enviando mensaje rápido #$i');
        stopwatch
          ..reset()
          ..start();
        
        // Simular envío de mensaje rápido (sin esperar en la UI, directo al ViewModel)
        try {
          await chatbotVm.sendMessage('Test de carga #$i');
          stopwatch.stop();
          debugPrint('[OK] Mensaje #$i procesado en ${stopwatch.elapsedMilliseconds} ms');
        } catch (e) {
          stopwatch.stop();
          debugPrint('[WARNING] Error/Rate Limit atrapado en mensaje #$i tras ${stopwatch.elapsedMilliseconds} ms: $e');
        }
      }
      
      debugPrint('[INFO] Verificando estabilidad del árbol de widgets tras la ráfaga');
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      
      debugPrint('[SUCCESS] La app sobrevivió al test de Rate Limiting correctamente');
    } catch (e) {
      debugPrint('[ERROR] Fallo crítico durante la prueba de Rate Limit: $e');
      fail('La aplicación falló inesperadamente: $e');
    }
  });
}
