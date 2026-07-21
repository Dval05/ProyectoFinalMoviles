import 'package:flutter_driver/driver_extension.dart';
import 'package:frontend/main.dart' as app;

void main() {
  // Habilita la extensión para que Appium se pueda comunicar
  enableFlutterDriverExtension();
  
  // Ejecuta la app normal
  app.main();
}
