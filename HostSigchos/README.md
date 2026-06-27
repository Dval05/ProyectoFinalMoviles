# HostSigchos 🏨

HostSigchos es un Sistema Integral de Reservas para Hosterías ubicado en el cantón Sigchos. Construida con **Flutter** y respaldada por **Firebase**, esta aplicación móvil ofrece una experiencia de usuario rápida, moderna y segura, siguiendo estrictamente los principios de **Arquitectura Limpia (Clean Architecture)**.

La aplicación está diseñada tanto para **Usuarios/Turistas** (que buscan descubrir y reservar hospedaje) como para **Propietarios** (que gestionan sus hosterías, habitaciones y reservas).

---

## ✨ Características Principales

### 🔐 Autenticación y Seguridad Avanzada
- **Inicio de Sesión Múltiple**: Soporte nativo para Google Sign-In (`google_sign_in`) y correo/contraseña clásica.
- **Vínculo de Credenciales**: Los usuarios registrados con Google pueden vincular una contraseña clásica para iniciar sesión de ambas maneras de forma unificada.
- **Autenticación Biométrica (Huella/Face ID)**: Posibilidad de guardar credenciales de forma segura usando `flutter_secure_storage` y acceder rápidamente a la app mediante `local_auth`.
- **Verificación en Dos Pasos (OTP)**: Verificación de identidad mediante envío de códigos OTP a través de correo electrónico y/o mensajes SMS para mayor seguridad.
- **Gestión de Perfiles**: Actualización de datos personales, teléfono, cédula y control de visibilidad de contraseñas.

### 🏨 Gestión de Hosterías y Habitaciones
- **Exploración y Filtrado**: Búsqueda avanzada de hosterías por nombre, rango de precios, ubicación (cercanía), ordenamiento alfabético y valoración (rating).
- **Geolocalización y Mapas**: Integración con OpenStreetMap (`flutter_map`) y Geolocalización (`geolocator`, `latlong2`) para ubicar las hosterías y mostrar las más cercanas al usuario.
- **Clima en Tiempo Real**: Consumo de API de clima para mostrar la temperatura y condiciones actuales en Sigchos.
- **Reseñas y Valoraciones**: Sistema de rating para las hosterías.
- **Galería de Imágenes**: Visualización de hosterías y habitaciones usando galerías fotográficas conectadas a Firebase Storage (`cached_network_image`, `carousel_slider`).

### 🛒 Reservas y Carrito
- **Carrito de Reservas**: Los usuarios pueden añadir múltiples habitaciones de una hostería a su carrito antes de confirmar la reserva.
- **Verificación de Disponibilidad**: Validación en tiempo real para evitar reservas solapadas en las mismas fechas.
- **Historial de Reservas**: Seguimiento detallado de todas las reservas realizadas (pasadas, activas, canceladas).

### 💳 Pagos y Estados Dinámicos
- **Integración de Pagos**: Soporte para registrar pagos (Transferencia, Deuna, etc.).
- **Transiciones de Estado Inteligentes**:
  - Los pagos manuales ingresan en estado `en_revision`.
  - **Transición Automática (48 horas)**: Si pasan 48 horas sin que el administrador confirme el pago, la reserva cambia automáticamente a `pendiente` o se cancela.
- **Notificaciones Push Locales**: Sistema de alertas en segundo plano (`flutter_local_notifications`) que advierte a los usuarios sobre confirmaciones de reserva, pagos pendientes y recordatorios.

### 🎁 Promociones
- Módulo de promociones para destacar ofertas especiales, descuentos temporales o paquetes en las hosterías.

### 🌍 Internacionalización (L10n)
- Soporte nativo multilenguaje (Español e Inglés), permitiendo al usuario cambiar el idioma de la aplicación dinámicamente.

### 👨‍💼 Panel de Propietario (Gestión)
- Vistas específicas para que los administradores y dueños de hosterías puedan gestionar su inventario, aprobar/rechazar pagos, y administrar las reservas entrantes.

---

## 🛠 Arquitectura (Clean Architecture)

El proyecto está diseñado para ser altamente escalable y mantenible, dividiendo el código en tres capas principales dentro del directorio `lib/`:

1. **Presentation Layer (`presentation/`)**: 
   - Contiene las interfaces gráficas (`views/`), rutas (`routes/`), y componentes reutilizables (`widgets/`).
   - El estado de la aplicación se maneja utilizando el patrón **ViewModel** inyectado a través de **Provider** (`viewmodels/`).
2. **Domain Layer (`domain/`)**: 
   - El núcleo de la aplicación, agnóstico a cualquier tecnología externa.
   - Contiene las **Entities** puras (Usuario, Hosteria, Habitacion, Reserva, Pago, Promocion).
   - Define los contratos mediante **Repositories Interfaces**.
   - Contiene los **Use Cases** que encapsulan toda la lógica de negocio (ej. `crear_reserva_usecase.dart`, `verificar_disponibilidad_usecase.dart`).
3. **Data Layer (`data/`)**: 
   - Implementa los contratos definidos en el dominio.
   - **Datasources**: Fuentes de datos específicas (Firebase Auth, Cloud Firestore, Firebase Storage, APIs REST para Geocoding y Clima, almacenamiento local).
   - **Repositories Impl**: Adaptadores que transforman los datos en crudo desde los datasources hacia las entidades del dominio.
4. **Core Layer (`core/`)**: 
   - Servicios transversales (`NotificationService`), utilidades, constantes globales, manejo de errores y soporte para internacionalización (`l10n/`).

---

## 🚀 Requisitos y Configuración

- **Flutter SDK**: `^3.12.1` (o superior)
- **Dart SDK**: Configurado de manera nativa con Flutter.
- **Dependencias nativas**:
  - `minSdkVersion` 23 (Android) debido a la biometría y requerimientos modernos de Firebase.
  - `ios/Podfile` preparado con target `>= 13.0`.

### Instalación

1. Clona este repositorio:
   ```bash
   git clone <url-del-repositorio>
   ```
2. Instala las dependencias:
   ```bash
   cd HostSigchos
   flutter pub get
   ```
3. Configuración de Entorno:
   - Asegúrate de tener el archivo `.env` en la raíz del proyecto (requerido para claves de API como clima o geocoding).
   - El archivo `firebase_options.dart` y los archivos de configuración nativos (`google-services.json`, `GoogleService-Info.plist`) deben estar configurados si apuntas a tu propio entorno de Firebase.
4. Ejecuta el proyecto en tu dispositivo o emulador:
   ```bash
   flutter run
   ```

---

## 📦 Tecnologías y Paquetes Clave

- **Backend (BaaS)**: 
  - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Arquitectura y Estado**: 
  - `provider`
- **Seguridad**: 
  - `local_auth` (Biometría)
  - `flutter_secure_storage` (Tokens y credenciales)
- **Mapas y Ubicación**: 
  - `flutter_map`, `latlong2`
  - `geolocator`
- **Notificaciones**: 
  - `flutter_local_notifications`
- **UI & Diseño**: 
  - `google_fonts` (Tipografía)
  - `carousel_slider`, `cached_network_image`, `shimmer` (Manejo de imágenes y loaders)
  - `flutter_rating_bar` (Componentes de calificación)
  - `country_picker`, `intl` (Localización y formatos)
- **Utilidades**: 
  - `flutter_dotenv` (Variables de entorno)
  - `http` (Peticiones API externas)

---

## 👥 Contribución y Buenas Prácticas

Antes de realizar un commit o subir cambios (Pull Request), asegúrate de que el código cumpla con los estándares de calidad del proyecto:

1. Analizar código (Linter):
   ```bash
   flutter analyze
   ```
2. Formatear código:
   ```bash
   flutter format lib/
   ```
