# Configuraci贸n de Pruebas con Appium Completada

La estructura de tu proyecto ya est谩 lista para poder ejecutar pruebas automatizadas con Appium sobre la aplicaci贸n desarrollada en Flutter.

## Cambios Realizados

- Se ha agregado la dependencia `flutter_driver` en tu `pubspec.yaml` y se ejecut贸 `flutter pub get`.
- Se ha creado el archivo de entrada `lib/main_appium.dart`. Este archivo envuelve el inicio normal de tu app con la extensi贸n `enableFlutterDriverExtension()` requerida por Appium para inspeccionar elementos de Flutter.
- Se ha creado una carpeta independiente `appium_tests` donde residir谩n los scripts de prueba.
- Dentro de `appium_tests`, se ha creado un `package.json` para gestionar dependencias de Node.js (`webdriverio` y `appium-flutter-driver`).
- Se elabor贸 un script b谩sico `appium_tests/sample_test.js` que se conecta a Appium, lanza la aplicaci贸n e ilustra c贸mo esperar que carguen elementos.

## Pasos para Ejecutar tu Primera Prueba

Como Appium requiere interacci贸n con dispositivos reales o emuladores del sistema operativo, aqu铆 tienes la gu铆a para arrancar tus pruebas:

### 1. Iniciar Appium (Requisito previo)
Si a煤n no tienes Appium instalado en tu computadora, debes instalarlo abriendo una terminal de Windows y ejecutando:
```bash
npm install -g appium
```
Luego inicia el servidor ejecutando simplemente:
```bash
appium
```
> [!IMPORTANT]
> Deja esa terminal abierta para que el servidor de Appium siga corriendo en segundo plano (generalmente en `http://127.0.0.1:4723`).

### 2. Compilar e Instalar tu App
Aseg煤rate de tener un emulador Android abierto (puedes verificarlo con `adb devices`).
Luego, compila e instala la aplicaci贸n con la extensi贸n de Appium habilitada, corriendo esto en la carpeta `HostSigchos-Tests`:
```bash
flutter run lib/main_appium.dart
```
> [!NOTE]
> Esto instalar谩 la app en el emulador. Puedes cerrar la app manualmente despu茅s de que inicie, ya que Appium se encargar谩 de levantarla de nuevo.

### 3. Ejecutar el Script de Prueba
Abre otra terminal, navega a la carpeta de las pruebas y ejecuta el test:
```bash
cd "d:\ESPE - ISOW\SEXTO_SEMESTRE\HostSigchos-AppMovil\HostSigchos-Tests\appium_tests"
node sample_test.js
```

### Notas adicionales:
Si deseas inspeccionar los elementos de Flutter para saber c贸mo referenciarlos (por ejemplo usando llaves `ValueKey`), puedes asignar `key: const Key('mi_boton')` a tus widgets y luego buscar por el id respectivo usando las utilidades de WebdriverIO.


## Ejecuci髇 de Pruebas Unitarias y Widgets
Para ejecutar todas las pruebas locales (modelos, providers, auth y UI en memoria), ejecuta en esta misma carpeta:
``bash
flutter test
``

## Ejecuci髇 de Pruebas de Integraci髇 (Nativas)
Las pruebas de integraci髇 en Flutter usan un driver distinto a Appium y son m醩 r醦idas para probar la UI puramente en Flutter.
Para ejecutarlas en el emulador:
``bash
flutter drive --driver=test_driver/app_test.dart --target=test/integration/app_test.dart
``

