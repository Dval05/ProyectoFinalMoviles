# Informe Final: Sistema de Reservas de Hosterías de Sigchos

**Institución:** Universidad de las Fuerzas Armadas ESPE
**Estudiante:** [Tu Nombre]
**Materia:** Aplicaciones Móviles
**Docente:** [Nombre del Docente]

---

## Introducción
El cantón Sigchos posee un enorme potencial turístico; sin embargo, gran parte de sus hosterías operan mediante sistemas de reservación tradicionales y manuales. "HostSigchos" surge como una solución tecnológica móvil que centraliza y facilita la gestión de reservas turísticas de las hosterías de Sigchos. La plataforma permite a los usuarios finales consultar disponibilidad de habitaciones, explorar instalaciones, realizar reservaciones seguras y ejecutar pagos electrónicos, ofreciendo una experiencia moderna, amigable y adaptada a las necesidades actuales.

## Planteamiento del problema
Actualmente, las hosterías del cantón Sigchos poseen procesos de reserva predominantemente manuales (vía telefónica o mensajería informal). Esto genera dificultades en la gestión y actualización en tiempo real de la disponibilidad de habitaciones, causando posibles reservas superpuestas, pérdida de clientes potenciales debido a demoras en la atención y una limitación significativa en el alcance comercial de las hosterías en un entorno digital.

## Objetivo general
Desarrollar una aplicación móvil integral para la gestión de reservas turísticas de las hosterías del cantón Sigchos, permitiendo a los turistas consultar disponibilidad, visualizar instalaciones, reservar habitaciones y efectuar pagos electrónicos seguros de manera intuitiva.

## Objetivos específicos
1. Desarrollar módulos de autenticación segura utilizando Firebase Authentication.
2. Implementar un catálogo dinámico de hosterías (incluyendo "El Trapiche", "San José", entre otras) con geolocalización mediante OpenStreetMap (GPS).
3. Gestionar consultas de disponibilidad, cálculo de tarifas y procesos de reservas integrados con la base de datos Firestore.
4. Gestionar los pagos de forma externa, registrando su comprobación en el sistema para confirmar las reservas y mantener un historial transaccional de los usuarios sin utilizar una pasarela interna.
5. Emplear metodologías y arquitecturas de código limpio (Clean Architecture y MVVM) garantizando la escalabilidad y mantenimiento del software.

## Alcance
El sistema está dirigido a turistas que deseen visitar Sigchos y requieran hospedaje, así como indirectamente a los administradores de hosterías. Contempla el desarrollo de una App para plataformas móviles, el uso de hardware (GPS, Cámara), la integración de bases de datos en tiempo real (Firebase), una interfaz en múltiples idiomas (Internacionalización) y la gestión de pagos de forma externa (comprobación de comprobantes o transferencias). 

## Arquitectura del sistema
Se implementó **Clean Architecture** junto al patrón **MVVM** para separar responsabilidades. 
*   **Inyección de dependencias:** Uso de `GetIt` para proveer instancias de servicios sin saturar el punto de arranque.
*   **Manejo de Estado:** Uso de `Provider` para reflejar automáticamente los cambios del modelo de datos en la interfaz.
*   **Capas:** 
    *   **Domain:** Lógica pura de negocio (Entidades, Casos de uso).
    *   **Data:** Repositorios, acceso a Firebase Firestore y llamadas a APIs REST externas.
    *   **Presentation:** Interfaces, Navegación y ViewModels.

## Diagrama de carpetas
La estructura principal del código fuente en `lib/` es:

```text
lib/
├── core/             # Servicios base (Notificaciones), l10n, configuraciones.
├── data/             # Modelos de datos y repositorios de conexión.
├── domain/           # Entidades (usuario, reserva) y casos de uso.
├── presentation/     # Pantallas y gestores de estado.
│   ├── routes/       # Rutas de navegación.
│   ├── viewmodels/   # ViewModels (Provider).
│   ├── views/        # Interfaces UI (Auth, Home, Reservas, Mapas).
│   └── widgets/      # Componentes visuales reutilizables.
├── themes/           # Paletas de color, tipografías y estilos.
├── utils/            # Constantes y funciones de ayuda.
├── main.dart         # Punto de entrada de la aplicación.
└── injection_container.dart # Configuración de GetIt.
```

## Modelo de datos
El sistema emplea bases de datos NoSQL mediante **Firebase Firestore**. 
Las colecciones implementadas son:
*   **habitaciones:** Tipos de cuarto, tarifas y relación con la hostería correspondiente.
*   **hosterias:** Contiene datos del establecimiento, servicios, fotografías, ubicación GPS y contactos.
*   **notificaciones:** Registro de alertas y mensajes enviados al usuario.
*   **promociones:** Descuentos y ofertas especiales aplicables a reservas.
*   **propietarios:** Almacena la información de los administradores de los establecimientos.
*   **reservas:** Registros con fechas de ingreso/salida, usuario, habitación seleccionada, estado de confirmación (validado mediante pago externo) y costo total.
*   **usuarios:** Almacena la información de los perfiles turísticos y de clientes.

## Capturas de la aplicación
*(Nota: Añade aquí las capturas de pantalla de las pantallas funcionales: 1. Login/Registro, 2. Home/Exploración, 3. Detalle de Hostería y Habitaciones, 4. Flujo de Reserva y Mapa).*

## Evidencia de pruebas
*(Nota: Adjunta evidencias del despliegue del APK en un dispositivo físico, el funcionamiento del hardware (uso de GPS) y los datos impactando en tiempo real en la consola de Firebase).*

## Conclusiones
*   La integración de **Clean Architecture** y el patrón **MVVM** permitió que la aplicación tenga un código desacoplado, facilitando la adición de nuevas funcionalidades y evitando errores de interfaz, obteniendo una aplicación robusta.
*   La delegación de servicios hacia plataformas como **Firebase** (Firestore y Auth) redujo los tiempos de desarrollo de backend, permitiendo que la persistencia de datos y el flujo de sesión sean seguros y en tiempo real.
*   El uso de herramientas de código abierto como **OpenStreetMap** demostró que se pueden construir mapas dinámicos eficientes y libres de costos recurrentes, logrando un producto altamente escalable para el turismo de Sigchos.
*   El proyecto HostSigchos soluciona eficazmente el problema de gestión de reservas, brindando una plataforma que moderniza los servicios turísticos locales.
