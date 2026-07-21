# Informe 3.2: Avance del Proyecto

**Estudiante:** [Tu Nombre]
**Materia:** Aplicaciones Móviles
**Proyecto:** Sistema de Reservas de Hosterías de Sigchos (HostSigchos)

---

## 1. Avance técnico
El proyecto se encuentra en un estado funcional avanzado. Se ha desarrollado una aplicación móvil completa utilizando **Flutter (Dart)** para el frontend y los servicios de **Firebase** para el backend (Authentication, Firestore, Storage). La aplicación implementa inyección de dependencias para mantener un código limpio y escalable, y usa `Provider` como gestor de estados principal. Además, se han integrado APIs externas, como **Groq API** para un chatbot, y **OpenStreetMap** para la geolocalización.

## 2. Arquitectura aplicada
Se aplicó un enfoque basado en **Clean Architecture** y **MVVM (Model-View-ViewModel)**. El código está dividido en tres capas principales:
*   **Capa Domain (Reglas de Negocio):** Contiene entidades y Casos de Uso.
*   **Capa Data (Datos):** Contiene repositorios y DataSources (interacción con `cloud_firestore` y APIs).
*   **Capa Presentation (Interfaz Gráfica):** Contiene Rutas, ViewModels (Manejo de Estado con `Provider`) y Vistas.
Se implementó el patrón Singleton junto con Inyección de Dependencias utilizando el paquete `get_it` para desacoplar responsabilidades.

## 3. Estructura del proyecto
La estructura principal dentro del directorio `lib` es la siguiente:
*   `core/`: Contiene configuraciones globales, internacionalización (`l10n`) y servicios (ej. `notification_service`).
*   `data/`: Modelos (`hosteria_model.dart`, `habitacion_model.dart`, etc.), repositorios y fuentes de datos.
*   `domain/`: Entidades y casos de uso de la aplicación.
*   `presentation/`: 
    *   `routes/`: Definición y manejo de rutas.
    *   `viewmodels/`: Clases ViewModel que gestionan el estado (Auth, Hosteria, Reserva, etc.).
    *   `views/`: Pantallas de la aplicación (Auth, Home, Mapa, Perfil, etc.).
    *   `widgets/`: Componentes UI reutilizables.
*   `themes/`: Definición del tema visual de la aplicación.
*   `utils/`: Utilidades y funciones auxiliares.

## 4. Pantallas desarrolladas
Se han desarrollado las siguientes pantallas principales dentro de `lib/presentation/views/`:
*   **Auth:** Login, Registro.
*   **Home:** Pantalla principal (Landing y Dashboard).
*   **Hostería:** Detalle de la hostería y catálogo.
*   **Habitaciones:** Exploración de disponibilidad y tarifas.
*   **Reservas:** Proceso de selección de fechas, resumen y pago de reservas.
*   **Transacción:** Historial de pagos y confirmaciones.
*   **Perfil:** Gestión de la cuenta y preferencias de idioma.
*   **Mapa:** Localización GPS con mapas de OpenStreetMap.
*   **Chatbot:** Asistente inteligente usando Groq AI.
*   **Notificaciones:** Bandeja de alertas del sistema.

## 5. Código principal explicado
El punto de entrada de la aplicación se encuentra en `lib/main.dart`. 
En este archivo, la lógica está aislada en inicializaciones concretas:
1.  **`Firebase.initializeApp`**: Conecta la aplicación a los servicios de backend.
2.  **`setupLocator()`**: Inicializa el contenedor de inyección de dependencias (`get_it`), registrando casos de uso, repositorios y servicios.
3.  **`MultiProvider`**: Carga todos los ViewModels necesarios (ej. `AuthViewModel`, `HosteriaViewModel`, `ReservaViewModel`, `LocaleViewModel`) para proveer el estado global de forma reactiva en el árbol de widgets.
4.  **`MaterialApp`**: Configura temas, enrutamiento base (`AppRoutes`), e internacionalización soportando inglés (`en`) y español (`es`).

## 6. Base de datos utilizada
Se utilizó **Firebase Firestore**, una base de datos NoSQL. El modelo de datos estructurado contempla las siguientes colecciones:
*   `habitaciones`
*   `hosterias`
*   `notificaciones`
*   `promociones`
*   `propietarios`
*   `reservas`
*   `usuarios`

## 7. Evidencia de funcionamiento
*(Nota: Adjunta aquí capturas de pantalla de la aplicación corriendo en tu emulador o dispositivo físico, mostrando el Login, el Home, el Mapa de Hosterías y el proceso de Reserva funcional).*

## 8. Problemas encontrados
*   **Acoplamiento en la vista:** Inicialmente había mucha lógica de cálculo de precios y filtros dentro de las pantallas. Esto se resolvió delegando la lógica a los *ViewModels*.
*   **Dependencia en APIs cerradas:** Se tuvo una dependencia alta en Google Maps, lo cual fue solucionado migrando la visualización de mapas a *OpenStreetMap*.
*   **Textos quemados en UI:** Se encontraron errores visuales con strings directos, lo que obligó a implementar internacionalización con `flutter_localizations` (`.arb` files).

## 9. Mejoras pendientes
*   Realizar despliegue y distribución controlada utilizando *Firebase App Distribution*.
*   Completar las pruebas Unitarias y de Integración.
*   Generar un APK final firmado y ofuscado completamente para Producción.
