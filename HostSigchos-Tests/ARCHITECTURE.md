# 🏗️ HostSigchos - Arquitectura y Clean Code

Este proyecto está construido siguiendo los principios de **Clean Code** y metodologías SOLID, priorizando el mantenimiento a largo plazo y la escalabilidad.

## 1. Patrón Singleton & Inyección de Dependencias (DI)

Uno de los mayores problemas detectados fue la instanciación de dependencias directamente en el `main.dart`, violando el principio de **Responsabilidad Única (SRP)**.

**Solución Implementada:**
*   Se introdujo el paquete `get_it`.
*   Creamos un archivo central: `lib/injection_container.dart` (también conocido como Localizador de Servicios).
*   **Beneficio**: `main.dart` ahora sólo tiene la responsabilidad de lanzar la app y configurar la UI principal, delegando la creación de Casos de Uso, ViewModels, y Fuentes de Datos a `get_it`. Esto hace que el código sea testeable y profesional.

## 2. Separación de Capas (Domain-Driven Design simplificado)

El proyecto está organizado en 3 capas principales:

1.  **Capa Domain (Reglas de Negocio):** Contiene entidades y Casos de Uso (ej. `crear_reserva_usecase.dart`). Esta capa no sabe nada sobre Firebase, bases de datos o UI.
2.  **Capa Data (Datos):** Contiene los repositorios y DataSources (Fuentes de Datos). Aquí interactuamos con `cloud_firestore`, APIs externas y persistencia local.
3.  **Capa Presentation (Interfaz Gráfica):** Contiene las Rutas, ViewModels (Manejo de Estado con `Provider`) y las Vistas/Widgets (UI en Flutter).

## 3. Corrección de Bugs en UI y Refactorización

*   **Evitamos lógicas de negocio complejas en las vistas**. Los cálculos de precio, filtrado y sorteo son responsabilidad de los `ViewModels`.
*   **Corrección de strings directos**: Se corrigieron errores visuales en las vistas (como la `r` raw string que causaba que las fechas se imprimieran mal en pantalla).
*   **Dependencias de UI**: Promovimos el principio de "Single Responsibility" en las vistas, separando la instanciación de clases como `NotificationService` hacia `get_it`, asegurando el principio de Inversión de Dependencias (Dependency Inversion Principle).

## 4. Internacionalización (i18n)

*   Se implementó el paquete oficial `flutter_localizations` utilizando archivos `.arb` (Application Resource Bundle) estandarizados.
*   **Separación Textual:** La UI no tiene strings quemados; todo el texto se inyecta mediante `AppLocalizations.of(context)`. Esto facilita la escalabilidad y permite soportar inglés (`en`) y español (`es`) dinámicamente.

## 5. Mapas Libres e Independencia de Proveedores

*   Se eliminó la dependencia cerrada de Google Maps API y Stripe, optando por proveedores abiertos como **OpenStreetMap (OSM)**, lo que reduce costos operativos y mejora el control arquitectónico del sistema.
