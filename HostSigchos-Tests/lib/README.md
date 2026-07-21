# Código Fuente (lib/) y Clean Architecture 🧩

Esta carpeta (`lib/`) alberga todo el código puro en Dart y Flutter para la aplicación móvil. Hemos adoptado el patrón **Clean Architecture** promovido por Uncle Bob, para que nuestro código sea mantenible, testeable y fácilmente actualizable.

## Entendiendo el flujo (Las Capas)

La regla de oro de Clean Architecture es la **Regla de Dependencia**: el código solo debe apuntar hacia el interior. La capa externa (Presentation o Data) depende de la capa interna (Domain), pero la capa de Domain nunca dependerá de nada externo.

### 1. `domain/` (El Centro del Sistema)
*   **¿Qué hace?** Es el corazón de tu aplicación. Contiene la lógica de negocio pura en lenguaje Dart. Aquí **no existe** Firebase, ni Flutter, ni HTTP.
*   **Archivos internos:**
    *   `entities/`: Objetos puramente abstractos de negocio (Ej: `Usuario.dart`, `Reserva.dart`).
    *   `repositories/`: Contratos (Interfaces o clases abstractas) que dictan cómo deben comportarse las bases de datos.
    *   `usecases/`: Los "Casos de Uso". Las reglas operativas y funcionales (Ej: `crear_reserva_usecase.dart` y `check_disponibilidad_usecase.dart`).

### 2. `data/` (El Exterior)
*   **¿Qué hace?** Habla con el mundo real y convierte esa información para que el dominio la entienda. Cumple los contratos dictados por el `domain/repositories/`.
*   **Archivos internos:**
    *   `datasources/`: La conexión real a Firebase, a la API de clima o a Gemini.
    *   `models/`: Clases que extienden las `Entities` pero que saben cómo transformarse de JSON o Firestore Snapshot a un objeto.
    *   `repositories/`: La implementación real de la base de datos (Ej: `auth_repository_impl.dart`).

### 3. `presentation/` (Lo Visual y el Estado)
*   **¿Qué hace?** Construye la interfaz gráfica y se comunica con el usuario usando Flutter y **MVVM**.
*   **Archivos internos:**
    *   `views/`: Las pantallas y páginas (UI).
    *   `widgets/`: Botones, inputs y componentes reutilizables.
    *   `viewmodels/`: (Gestores de estado con **Provider**). Actúan como intermediarios entre la Vista y los Casos de Uso del Dominio. Si el usuario presiona "Reservar", la vista llama al `ReservaViewModel`, que a su vez llama al `CrearReservaUseCase`.

---

## Otras carpetas misceláneas
- **`core/`**: Funciones utilitarias, validadores de correos/contraseñas, constantes estáticas y manejo global de errores (`Failures`).
- **`themes/`**: Colores globales (`Colors`), tipografías (`TextTheme`) y configuraciones de diseño.
- **`main.dart` y `injection_container.dart`**: Archivos de entrada que inicializan el árbol de Flutter, configuran Firebase y conectan todas las capas mediante `GetIt` (Inyección de dependencias).
