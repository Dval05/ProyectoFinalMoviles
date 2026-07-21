# Entorno de Pruebas (Testing) 🧪

La carpeta `test/` contiene la suite de control de calidad del código. Es la evidencia programática de que las pantallas y la lógica de negocio se comportan de manera predecible, mitigando vulnerabilidades.

## Tipos de Pruebas Implementadas

### 1. `unit/` (Pruebas Unitarias)
Valida funciones y Casos de Uso específicos de la capa de *Domain* o *Data*.
*   **Funcionamiento:** Utilizamos **Mockito** para crear *mocks* (simulaciones) de nuestras bases de datos.
*   **Caso Destacado:** El test `verificar_disponibilidad_usecase_test.dart` no se conecta a Firebase. Simula reservas en memoria con fechas futuras y pasadas, y evalúa la fórmula matemática del `checkIn.isBefore(r.fechaCheckOut)` para garantizar que el sistema siempre proteja a la hostería del "Overbooking".

### 2. `widget/` (Pruebas de Componentes)
Aíslan un pedazo de interfaz para testear su renderizado en Flutter sin levantar una aplicación completa.
*   **Funcionamiento:** Instancia widgets como `LoginScreen` dentro de un entorno virtual llamado `WidgetTester`. Simulamos un toque en la pantalla (`tester.tap()`) o escribimos texto artificial (`tester.enterText()`) apuntando a las llaves `Key()` inyectadas en los inputs.
*   **Validación:** Nos aseguramos de que presionar "Iniciar sesión" invoque a nuestro `AuthViewModel` sin lanzar pantallas rojas de error gráfico.

### 3. `integration/` y `test_driver/` (Appium / E2E)
Pruebas integrales automáticas "End to End" (De principio a fin).
*   **Funcionamiento:** En lugar de aislar el código, estas pruebas *instalan* y *levantan* la app entera. Simulan un humano real recorriendo la app (con sus demoras y tiempos de carga a través de la red).
*   **Seguridad:** Dado que una prueba real requiere loguearse a la plataforma viva (Firebase Auth real), leemos las credenciales `email` y `password` directamente de tu archivo `.env` local para evitar que queden registradas permanentemente en el código.

---

## 🚀 Cómo correr las pruebas paso a paso

Siéntete libre de verificar la salud del proyecto en cualquier momento usando la CLI nativa de Dart:

1.  Abre tu terminal integrado en VSCode (Asegúrate de estar en `HostSigchos-Tests`).
2.  Ejecuta el siguiente comando para correr toda la suite de golpe:
    ```bash
    flutter test
    ```
3.  **Para probar integración (Requiere emulador encendido):**
    ```bash
    flutter test integration_test/app_test.dart
    ```
