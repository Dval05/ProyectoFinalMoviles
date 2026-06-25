# HostSigchos 🏨

HostSigchos es una aplicación móvil desarrollada en **Flutter** diseñada para la gestión y reserva de hosterías en el cantón Sigchos, Ecuador. La aplicación permite a los usuarios buscar hospedaje, visualizar detalles de hosterías y habitaciones, consultar disponibilidad mediante un calendario, y realizar reservas.

## 📋 Tabla de Contenidos

1. [Especificaciones Técnicas](#especificaciones-técnicas)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Requisitos del Sistema (Hardware y Software)](#requisitos-del-sistema)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Configuración Inicial y Firebase](#configuración-inicial-y-firebase)
6. [Configuración de APIs (Google Maps)](#configuración-de-apis)
7. [Instalación y Ejecución](#instalación-y-ejecución)


---

## 🛠 Especificaciones Técnicas

### Tecnologías Principales
- **Framework:** Flutter (SDK ^3.12.1)
- **Lenguaje:** Dart
- **Gestor de Estado:** Provider (`^6.1.2`)
- **Backend / Base de Datos:** Firebase (Auth, Cloud Firestore, Firebase Storage)
- **Mapas y Geolocalización:** `google_maps_flutter`, `geolocator`, `http` (para Google Geocoding API).
- **Diseño UI:** Componentes personalizados con Material Design, `shimmer`, `carousel_slider`, `google_fonts`.

### Lógica de Negocio (Reglas de la App)
- **Capacidad Máxima por Reserva:** 8 huéspedes.
- **Estadía Máxima:** 30 noches.
- **Horarios:** Check-In a las 14:00 (2:00 PM), Check-Out a las 12:00 PM.
- **Moneda de Operación:** Dólares Estadounidenses (USD, $).
- **Ubicación Base:** Sigchos (Latitud: -0.7033, Longitud: -78.8878).

---

## 🏗 Arquitectura del Proyecto

El proyecto sigue los principios de **Clean Architecture**, dividiendo la aplicación en capas separadas para garantizar la escalabilidad, el mantenimiento y la separación de responsabilidades:

- **Domain Layer:** Contiene la lógica de negocio pura. Entidades (Models abstractos), Contratos de Repositorios y Casos de Uso (UseCases).
- **Data Layer:** Contiene las implementaciones de los repositorios y los DataSources (Firebase, Local, Mock, Remote APIS) y los Modelos de datos (con serialización JSON/Firestore).
- **Presentation Layer:** Contiene la Interfaz de Usuario (Views/Screens), los Widgets reutilizables, y la gestión del estado a través de los **ViewModels** (Provider).
- **Core Layer:** Contiene recursos comunes, constantes, manejo de errores, utilidades y la internacionalización (L10n).

> 💡 **Documentación Detallada de Archivos:** Para entender de forma exhaustiva el rol de cada archivo, qué datos recibe, qué información devuelve, y cómo viaja la información entre estas capas (desde la UI hasta Firebase), hemos preparado una [Documentación Detallada de Archivos y Flujo de Datos](DOCUMENTACION_ARCHIVOS.md). Te recomendamos revisarla para dominar la lógica interna del proyecto.

---

## 💻 Requisitos del Sistema

### Hardware
- **Procesador:** Intel Core i5 / AMD Ryzen 5 o superior (recomendado i7 o M1/M2 en Mac).
- **Memoria RAM:** Mínimo 8 GB (Recomendado 16 GB para ejecutar emuladores y el IDE fluidamente).
- **Almacenamiento:** Al menos 10 GB de espacio libre (preferiblemente SSD).
- **Dispositivos:** Emulador de Android, Simulador de iOS o Dispositivos Físicos conectados.

### Software
- **Sistema Operativo:** Windows 10/11, macOS, o Linux.
- **SDKs Necesarios:** 
  - Flutter SDK versión `>=3.12.1 <4.0.0`
  - Dart SDK
  - Android SDK (vía Android Studio)
  - Xcode (obligatorio si se compila para iOS en macOS)
- **IDE:** Android Studio, IntelliJ IDEA, o Visual Studio Code (con extensiones de Flutter y Dart instaladas).
- **Control de Versiones:** Git.

---

## 📂 Estructura del Proyecto

```text
HostSigchos/
├── android/               # Configuración nativa de Android
├── ios/                   # Configuración nativa de iOS
├── assets/                # Imágenes e íconos locales
├── lib/
│   ├── core/              # Constantes (app_constants), utilidades, errores
│   ├── data/              # Modelos, Repositories Impl, y DataSources (Firebase)
│   ├── domain/            # Entidades, Repositories interfaces, UseCases
│   ├── presentation/      # Pantallas (views), ViewModels (provider) y Widgets
│   ├── themes/            # Configuración visual global de la app (colores, tipografía)
│   └── main.dart          # Punto de entrada de la aplicación e Inyección de Dependencias
└── pubspec.yaml           # Archivo de configuración de dependencias de Flutter
```

---

## 🔥 Configuración Inicial y Firebase

La aplicación utiliza **Firebase** como Backend as a Service (BaaS). Para que la app funcione con datos reales, debes configurar un proyecto de Firebase:

1. **Crear el Proyecto:** Ve a la [Consola de Firebase](https://console.firebase.google.com/) y crea un nuevo proyecto llamado `HostSigchos`.
2. **Autenticación (Firebase Auth):** Habilita los proveedores de inicio de sesión **Correo electrónico/Contraseña** y **Google**.
3. **Base de Datos (Firestore):**
   - Crea una base de datos Cloud Firestore.
   - Colecciones requeridas (se crearán automáticamente según los modelos): `usuarios`, `hosterias`, `habitaciones`, `reservas`, `pagos`.
4. **Almacenamiento (Firebase Storage):** Habilita Storage para alojar las imágenes de las hosterías y habitaciones.
5. **Configurar FlutterFire:**
   Para conectar el código con tu proyecto de Firebase, utiliza FlutterFire CLI en la raíz del proyecto (`HostSigchos/`):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=TU_PROYECTO_ID
   ```
   Esto generará el archivo `firebase_options.dart` y colocará `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).

---

## 🗺 Configuración de Mapas y Geocoding

La aplicación utiliza **OpenStreetMap** (a través de `flutter_map`) para la visualización interactiva de mapas. No se requieren SDKs nativos ni claves de API para cargar el mapa.

Sin embargo, para el servicio de búsqueda de direcciones y coordenadas, se utiliza la **Geocoding API** de Google. 

Para configurarlo:
1. Ingresa a la [Consola de Google Cloud](https://console.cloud.google.com/).
2. Crea un proyecto o selecciona el proyecto vinculado a Firebase.
3. Habilita la **Geocoding API**.
4. Genera una clave de API (API Key) en la sección de *Credenciales*.
5. **Agrega la API Key al código:**
   - En el archivo `lib/core/constants/app_constants.dart`, reemplaza la variable con tu clave:
     ```dart
     static const String googleMapsApiKey = 'TU_GOOGLE_MAPS_API_KEY_AQUI';
     ```
   *(No es necesario modificar el AndroidManifest.xml ni el AppDelegate.swift para los mapas)*

---

## 🚀 Instalación y Ejecución

Sigue estos pasos para clonar e iniciar el proyecto localmente:

1. **Clonar el repositorio:**
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd ProyectoFinal/HostSigchos
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Verificar el entorno de Flutter:**
   Asegúrate de que no existan problemas de configuración ejecutando:
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación:**
   Abre un emulador o conecta un dispositivo y ejecuta:
   ```bash
   flutter run
   ```

---

