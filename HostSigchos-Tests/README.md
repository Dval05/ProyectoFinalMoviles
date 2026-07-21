# Aplicación Móvil HostSigchos (Flutter) 📱

Esta carpeta contiene el ecosistema móvil completo para el turista. Ha sido desarrollada bajo estrictos estándares de la industria, asegurando su escalabilidad, mantenimiento y cobertura de pruebas.

## 🏗️ Clean Architecture y MVVM

El proyecto está diseñado bajo el modelo **Clean Architecture**. Si abres la carpeta `lib/`, encontrarás que no todo está mezclado. En lugar de eso, el código fluye en capas que no dependen de la UI. 
* 📖 [Leer sobre la estructura de la carpeta `lib/`](./lib/README.md)

## 🧪 Pruebas y Control de Calidad (Testing)

Se ha implementado una estrategia profunda para garantizar cero errores en producción, especialmente para prevenir el temido *Overbooking* (Sobreventa) de habitaciones y para asegurar que la autenticación sea infalible.
* 📖 [Leer cómo ejecutar y comprender los Tests (`test/`)](./test/README.md)

## 🛠️ Tecnologías Clave Utilizadas
- **Gestor de Estado:** Provider (inyección de dependencias con GetIt).
- **Backend:** Firebase (Auth, Cloud Firestore para base de datos NoSQL documental, Storage para imágenes).
- **IA Generativa:** SDK de Gemini (Chatbot turístico interactivo).
- **Mapas:** `flutter_map` con servidor de geocoding.
- **Hardware Integrado:** Local Auth (Autenticación biométrica con huella/rostro), TTS (Texto a voz), Sensores de ubicación y brújula.

## 📝 Configuración y Ejecución Inicial (Paso a Paso)

1. **Variables de entorno:** Crea un archivo llamado `.env` en la raíz de esta carpeta y agrega las llaves API necesarias de Google/Firebase y Gemini.
2. **Descargar dependencias:**
   ```bash
   flutter pub get
   ```
3. **Generación de código:** (Importante si editas modelos o dependencias)
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```
4. **Ejecutar en el emulador o celular real:**
   ```bash
   flutter run
   ```
