# 🛡️ HostSigchos - Seguridad y Ofuscamiento

Este documento detalla las medidas de seguridad y ofuscamiento implementadas en el proyecto para proteger la integridad de los datos, evitar la ingeniería inversa y asegurar las claves de las APIs.

## 1. Ofuscamiento de Código Nativo (Android R8/ProGuard)

Para evitar que actores malintencionados descompilen el APK y lean el código, hemos habilitado **R8/ProGuard**:

*   **Archivo Modificado**: `android/app/build.gradle.kts`
*   **Configuración**:
    ```kotlin
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    ```
Esto asegura que los nombres de las clases, métodos y variables en la capa nativa se renombren a letras sin sentido (por ejemplo, `a.b.c()`) y elimina el código muerto, reduciendo el peso de la app.

## 2. Ofuscamiento de Variables de Entorno (API Keys)

Anteriormente, las claves de Firebase y Groq estaban en el archivo `.env` que se empaquetaba como un `asset` de texto plano. Esto es un fallo crítico de seguridad porque el APK es un simple archivo `.zip` que puede extraerse fácilmente.

**La Solución Implementada:**
Implementamos la librería `envied` y `envied_generator`.
*   Creamos `lib/core/constants/env.dart` con la anotación `@Envied(path: '.env', obfuscate: true)`.
*   Corrimos `flutter pub run build_runner build` para compilar un archivo `env.g.dart` que contiene las claves transformadas en arreglos de bytes ofuscados a nivel binario.
*   **El archivo `.env` original fue removido de los assets** en el `pubspec.yaml`, lo que asegura que nunca se envíe en el instalador de la app.

## 3. Seguridad de Red (Network Security Config)

Para asegurar que los datos no viajen interceptables (Ataques *Man in the Middle*), forzamos estrictamente el uso de HTTPS.

*   **Archivo Creado**: `android/app/src/main/res/xml/network_security_config.xml`
*   Configuramos `cleartextTrafficPermitted="false"`, asegurando que la aplicación **sólo** pueda comunicarse a través de protocolos cifrados.
*   Enlazamos esto en el `AndroidManifest.xml` añadiendo `android:networkSecurityConfig="@xml/network_security_config"`.

## 4. Manejo Seguro de Errores

Implementamos `ErrorHandler.getFriendlyMessage(error)` (`lib/core/utils/error_handler.dart`).
En lugar de mostrar excepciones crudas de bases de datos que revelan información de la arquitectura interna de la aplicación, el sistema intercepta excepciones (como de Firebase Auth) y presenta mensajes amigables al cliente, tales como:
> *"Problema de conexión. Verifica tu internet e inténtalo de nuevo."*
> *"Se ha producido un error interno. Inténtalo en unos minutos."*

Esto cumple el doble propósito de mejorar la Experiencia de Usuario (UX) y mitigar fugas de información técnica (Information Disclosure).

## 5. Prevención de Inserción de Datos Basura (Test Users)

Se ha realizado una revisión y limpieza global del código para evitar la inyección automática de usuarios o datos quemados (como cuentas *tester*) en las bases de datos de producción durante el arranque de la aplicación.
Toda la información sensible de contacto (correos de soporte y teléfonos) también ha sido extraída de la interfaz y configurada de forma segura a través de `Envied`.
