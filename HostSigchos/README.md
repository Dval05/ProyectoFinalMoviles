# HostSigchos 🏨

HostSigchos es un Sistema de Reservas para Hosterías ubicado en el cantón Sigchos. La aplicación móvil está construida con **Flutter** y **Firebase**, enfocada en ofrecer una experiencia de usuario rápida, moderna y segura, utilizando arquitectura limpia (Clean Architecture).

## ✨ Características Principales

### Autenticación y Seguridad Avanzada
- **Inicio de Sesión con Google**: Integración nativa usando `google_sign_in` (v7.2.0).
- **Vínculo de Credenciales**: Los usuarios registrados con Google pueden vincular una contraseña clásica para iniciar sesión de ambas maneras.
- **Biometría (Huella/Face ID)**: Posibilidad de guardar credenciales usando `flutter_secure_storage` y acceder a la aplicación escaneando el rostro o huella digital (`local_auth`).
- **Verificación OTP en dos pasos**: Verificación de identidad a través de correo electrónico y mensajes SMS para mayor seguridad tras el registro.
- **Visibilidad de contraseñas**: Control de visibilidad en campos de contraseña con un diseño intuitivo.

### Gestión de Reservas y Pagos
- **Estados de Pago Dinámicos**: Los métodos de pago que no son inmediatos (como Transferencia o Deuna) ingresan como `en_revision`.
- **Transición Automática (48 horas)**: Si pasan 48 horas sin confirmarse, la reserva cambia automáticamente al estado `pendiente`.
- **Notificaciones Locales (Push)**: Sistema de alertas en segundo plano (usando `flutter_local_notifications` v22.0+) que advierte a los usuarios sobre pagos pendientes y confirmaciones de reserva.

## 🛠 Arquitectura

El proyecto sigue los principios de **Clean Architecture**, dividiendo el código en tres capas principales:

1. **Presentation Layer**: Pantallas (`views`), widgets reutilizables, y manejo de estado a través de `Provider` (`viewmodels`).
2. **Domain Layer**: Reglas de negocio principales, entidades puras (`entities`), interfaces de repositorios (`repositories`) y casos de uso (`usecases`).
3. **Data Layer**: Implementación de repositorios, modelos de datos y fuentes de datos externas (Firebase Auth, Cloud Firestore, Firebase Storage y APIs REST).

## 🚀 Requisitos y Configuración

- **Flutter SDK**: `^3.12.1` (o superior)
- **Dart SDK**: Configurado de manera nativa con Flutter.
- **Dependencias nativas**:
  - `minSdkVersion` 23 (Android) debido a la biometría y Firebase.
  - `ios/Podfile` preparado con target `>= 13.0`.

### Instalación

1. Clona este repositorio.
2. Descarga las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta el proyecto en tu dispositivo o emulador:
   ```bash
   flutter run
   ```

## 📦 Tecnologías Clave

- `firebase_core`, `firebase_auth`, `cloud_firestore`: Backend y Base de datos (NoSQL).
- `provider`: Manejo de estados e inyección de dependencias simples.
- `local_auth` & `flutter_secure_storage`: Para inicio de sesión seguro y biométrico.
- `flutter_local_notifications`: Para notificaciones offline programadas.
- `google_maps_flutter` & `geolocator`: Mapas y geolocalización.

## 👥 Contribución

Asegúrate de ejecutar las herramientas de análisis de código antes de subir tus cambios:
```bash
flutter analyze
flutter format lib/
```
