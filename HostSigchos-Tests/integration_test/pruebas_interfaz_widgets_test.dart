
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Prueba de inspección de widgets e interfaz', (WidgetTester tester) async {
    debugPrint('[INFO] Iniciando conteo de widgets interactivos e interfaz gráfica');
    
    app.main();
    await tester.pumpAndSettle();
    
    debugPrint('[INFO] Árbol de widgets estabilizado. Realizando inspección.');

    final scaffoldCount = tester.widgetList(find.byType(Scaffold)).length;
    debugPrint('[TEST] Scaffolds encontrados: $scaffoldCount');
    
    final textCount = tester.widgetList(find.byType(Text)).length;
    debugPrint('[TEST] Textos encontrados: $textCount');

    final imageCount = tester.widgetList(find.byType(Image)).length;
    debugPrint('[TEST] Imágenes encontradas: $imageCount');

    // Conteo de elementos interactivos
    final elevatedBtnCount = tester.widgetList(find.byType(ElevatedButton)).length;
    final iconBtnCount = tester.widgetList(find.byType(IconButton)).length;
    final textBtnCount = tester.widgetList(find.byType(TextButton)).length;
    final gestureCount = tester.widgetList(find.byType(GestureDetector)).length;
    final inkWellCount = tester.widgetList(find.byType(InkWell)).length;
    
    final totalInteractive = elevatedBtnCount + iconBtnCount + textBtnCount + gestureCount + inkWellCount;
    debugPrint('[TEST] Elementos interactivos totales en pantalla: $totalInteractive');

    final bottomNavCount = tester.widgetList(find.byType(BottomNavigationBar)).length;
    if (bottomNavCount > 0) {
      debugPrint('[OK] BottomNavigationBar encontrado');
    } else {
      debugPrint('[INFO] BottomNavigationBar no encontrado en la vista actual (posiblemente pantalla Login/Splash)');
    }

    // Bombeando frames adicionales para probar el renderizado asíncrono
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    
    debugPrint('[SUCCESS] Prueba de inspección de widgets completada');
  });
}
