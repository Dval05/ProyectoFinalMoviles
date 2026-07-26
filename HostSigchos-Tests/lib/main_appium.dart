import 'package:flutter_driver/driver_extension.dart';
import 'package:frontend/main.dart' as app;

void main() {
  // Habilita la extensión para que Appium pueda interceptar los elementos de Flutter en el árbol
  enableFlutterDriverExtension();

  // Inicia la aplicación de forma normal
  app.main();
}
