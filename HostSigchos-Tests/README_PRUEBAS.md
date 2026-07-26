# 🧪 HostSigchos - Manual y Guía de Ejecución de Pruebas Automáticas

Este documento define las políticas, flujos de ejecución y métricas para el entorno de Quality Assurance (QA) del aplicativo móvil **HostSigchos**. La infraestructura automatizada está segmentada en capas utilizando la pirámide de testing.

> **⚠️ Requisito previo:** Todas las pruebas deben ejecutarse estando físicamente posicionados dentro del directorio del sub-proyecto de testing.
> En tu terminal de Android Studio o VS Code ejecuta:
> ```bash
> cd "D:\ESPE - ISOW\SEXTO_SEMESTRE\HostSigchos-AppMovil\HostSigchos-Tests"
> ```

---

## 1️⃣ Pruebas Unitarias Puras (Lógica Matemática sin UI)
Estas pruebas evalúan milisegundo a milisegundo las **Entidades de Dominio** (Hosteria, Habitacion, Reserva, Usuario, Resena, Notificacion, ChatMessage) y los **Casos de Uso**. No requieren iniciar un emulador ni dispositivo físico, corren de forma nativa en la memoria de la PC.

### 💻 Comando Maestro:
```bash
flutter test test/domain/ --reporter expanded
```
* **Métrica:** +32 pruebas (PU-01 a PU-32).
* **Evidencias (Capturas a tomar):** Toma una captura de pantalla separada por cada suite del reporte (9 en total) y nómbralas así:
  - `evidencia_pu_chatmessage.png` (Resultados de ChatMessage Entity Suite)
  - `evidencia_pu_habitacion.png` (Resultados de Habitacion Entity Suite)
  - `evidencia_pu_hosteria.png` (Resultados de Hosteria Entity Suite)
  - `evidencia_pu_notificacion.png` (Resultados de NotificacionApp Entity Suite)
  - `evidencia_pu_resena.png` (Resultados de Resena Entity Suite)
  - `evidencia_pu_reserva.png` (Resultados de Reserva Entity Suite)
  - `evidencia_pu_usuario.png` (Resultados de Usuario Entity Suite)
  - `evidencia_pu_crear_reserva.png` (Resultados de CrearReservaUseCase)
  - `evidencia_pu_verificar_disp.png` (Resultados de VerificarDisponibilidadUseCase)

---

## 2️⃣ Pruebas de Interfaz In-Memory (Widget Testing)
Aíslan componentes del frontend de Flutter (`GradientButton`, `CustomTextField`, `LoadingOverlay`) y simulan gestos humanos (taps) inyectando ViewModels (`MockAuthViewModel`, etc.) utilizando la librería de `Mockito` y `Provider`.

### 💻 Comando Maestro:
```bash
flutter test test/widget/ --reporter expanded
```
* **Métrica:** +16 pruebas (PW-01 a PW-16).
* **Evidencias (Capturas a tomar):**
  - `evidencia_pw_gradient_button.png` (Resultados de GradientButton Widget Suite)
  - `evidencia_pw_loading_overlay.png` (Resultados de LoadingOverlay Widget Suite)
  - `evidencia_pw_text_field.png` (Resultados de CustomTextField Widget Suite)
  - `evidencia_pw_home_screen.png` (Resultados de HomeScreen MultiProvider Suite)
  - `evidencia_pw_login_screen.png` (Resultados de LoginScreen Integration Suite)

---

## 3️⃣ Pruebas Nativas End-to-End (E2E)
Esta prueba levanta el driver de integración (`integration_test`), compila el motor de Flutter (Skia/Impeller) y **toma el control total del celular**. Simula a un humano invisible iniciando sesión, navegando entre pestañas, buscando hosterías y chateando con el Bot.

> 📱 **Importante:** Conecta tu celular físico Samsung por USB (con Depuración USB activada) y mantén la pantalla encendida.

### 💻 Comando Maestro:
```bash
flutter test integration_test/pruebas_e2e_completas_test.dart
```
* **Métrica:** 15 Pasos de Interacción (E2E-01 a E2E-15).
* **Evidencias (Capturas a tomar):**
  - `evidencia_e2e_1.png` y `evidencia_e2e_2.png` (Toma una o dos fotos a tu celular navegando solo).
  - `evidencia_e2e_consola.png` (La captura de tu PC al terminar).

---

## 4️⃣ Pruebas Funcionales Específicas
Pone a prueba de forma exclusiva la búsqueda algorítmica, los mapas y la geolocalización. Requiere conexión al celular real.

### 💻 Comando Maestro:
```bash
flutter test integration_test/pruebas_funcionales_test.dart
```
* **Evidencia:** `evidencia_funcionales.png`

---

## 5️⃣ Pruebas de Seguridad y Throttling (Rate Limit)
Bombardea y estresa la aplicación comprobando que los interceptores de red bloqueen los ataques y eviten que se envíen más peticiones de las permitidas al servidor (Código HTTP 429). Requiere celular real.

### 💻 Comando Maestro:
```bash
flutter test integration_test/pruebas_rate_limit_test.dart
```
* **Evidencia:** `evidencia_rate_limit.png`

---

## 6️⃣ Pruebas de Rendimiento, Rasterización y Latencia (CPU/GPU)
Registra los milisegundos de compilación fotograma por fotograma (`build_time` y `rasterizer_time`). Asegura que el hilo principal (Main Thread) renderice la aplicación a unos estables **60 FPS**. Requiere celular real.

### 💻 Comando Maestro:
```bash
flutter test integration_test/pruebas_rendimiento_test.dart
```
* **Evidencia:** `evidencia_rendimiento.png`
