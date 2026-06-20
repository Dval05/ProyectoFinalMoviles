# 📖 Documentación Detallada de Archivos y Flujo de Datos

Este documento explica en detalle cómo funciona cada directorio y tipo de archivo dentro de la arquitectura Clean Architecture del proyecto HostSigchos, incluyendo qué función cumplen, qué datos reciben y qué datos retornan.

---

## 🧭 Flujo General de la Aplicación

La aplicación funciona mediante un flujo unidireccional estricto:
1. El **Usuario** interactúa con una **View** (Pantalla).
2. La View llama a un método en el **ViewModel**.
3. El ViewModel ejecuta un **UseCase** (Caso de Uso del Dominio).
4. El UseCase llama al **Repository** (Interfaz en Dominio, implementado en Data).
5. El Repository_Impl llama al **DataSource** (Firebase o Mock).
6. El DataSource retorna un **Model** (JSON a Dart) al Repository.
7. El Repository lo devuelve como **Entity** al UseCase.
8. El UseCase retorna la Entity al ViewModel.
9. El ViewModel actualiza su estado (`notifyListeners()`) y la View se redibuja.

---

## 1. Capa `lib/core/` (Núcleo transversal)
Contiene las utilidades que cualquier otra capa de la aplicación puede importar.

### Archivos de Constantes (`core/constants/`)
* **`app_constants.dart`**
  * **Función:** Almacena valores constantes y parámetros de negocio estáticos.
  * **Recibe:** Nada.
  * **Da:** Variables como límites de reservas (`maxHuespedes`), coordenadas del mapa y el String de la API Key de Google Maps.
* **`firestore_paths.dart`**
  * **Función:** Centralizar los nombres de las colecciones de Firebase.
  * **Recibe:** Nada.
  * **Da:** Strings fijos (ej. `'habitaciones'`, `'reservas'`) para evitar errores de tipeo.

---

## 2. Capa `lib/domain/` (Reglas de Negocio)
La capa más interna. No depende de Flutter, Firebase ni de APIs.

### `domain/entities/` (ej. `reserva.dart`, `habitacion.dart`)
* **Función:** Representar los objetos base del negocio.
* **Recibe:** Datos primarios en el constructor.
* **Da:** Instancias seguras que circulan por toda la aplicación.

### `domain/repositories/` (ej. `reserva_repository.dart`)
* **Función:** Son "Contratos" o "Interfaces" abstractas. Definen QUÉ acciones se pueden hacer en la base de datos, sin importar cómo se hagan.
* **Recibe / Da:** Solo define firmas de funciones, por ejemplo: `Future<void> crearReserva(Reserva reserva);`

### `domain/usecases/` (ej. `crear_reserva_usecase.dart`)
* **Función:** Orquestar una tarea específica del negocio. Cada caso de uso hace una sola cosa.
* **Recibe:** El Repository a través del constructor. También recibe los parámetros que pide el usuario (ej. fechas de reserva).
* **Da:** Un `Future` con el resultado de la acción, retornando la respuesta del repositorio hacia la interfaz.

---

## 3. Capa `lib/data/` (Manejo de Datos y API)
Esta capa "sabe" que estamos usando Firebase o Mocks y convierte los JSON.

### `data/models/` (ej. `reserva_model.dart`)
* **Función:** Son extensiones de las *Entities* del dominio. Agregan la habilidad de serialización de la base de datos.
* **Recibe:** JSON desde Firestore (método `fromJson()` o `fromMap()`).
* **Da:** Objetos JSON hacia Firestore (método `toJson()`) e instancias de Entidades hacia el Dominio.

### `data/datasources/` (Firebase y Mocks)
* **`firebase/hosteria_datasource.dart`**:
  * **Función:** Comunicarse directamente con Firebase Cloud Firestore.
  * **Recibe:** IDs, JSONs y consultas de Firebase.
  * **Da:** Documentos de Firestore convertidos en *Models*.
* **`mock/mock_hosteria_datasource.dart`**:
  * **Función:** Simular respuestas de red en local.
  * **Recibe:** Lo mismo que el datasource de Firebase.
  * **Da:** Arrays estáticos precargados en memoria simulando un `Future.delayed`.

> 💡 **Nota sobre Firestore:** La aplicación está configurada explícitamente para conectarse a una base de datos nombrada (`databaseId: 'hostsigchos'`) en lugar de la base de datos `(default)`. Para ello, todos los DataSources de Firebase instancian Firestore usando `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos')`.

### `data/repositories/` (ej. `reserva_repository_impl.dart`)
* **Función:** Es la implementación real del contrato del Dominio. Une los DataSources con los Casos de Uso.
* **Recibe:** Un DataSource (Inyectado en constructor).
* **Da:** Los *Models* mapeados hacia las *Entities*, interceptando y manejando errores o excepciones de Firebase antes de que lleguen a la UI.

---

## 4. Capa `lib/presentation/` (Interfaz de Usuario)

### `presentation/viewmodels/` (ej. `reserva_viewmodel.dart`)
* **Función:** Son controladores que extienden `ChangeNotifier` de Provider. Manejan el estado y la lógica de interacción de las pantallas.
* **Recibe:** Uno o más *UseCases* en su constructor. Las interacciones del usuario (clics en botones, campos de texto).
* **Da:** Un estado reactivo a la UI. Expone variables como `bool isLoading`, `String? errorMessage` y Listas como `List<Reserva>`. Llama a `notifyListeners()` para indicar a la UI que se redibuje.

### `presentation/views/` (ej. `perfil_screen.dart`, `register_screen.dart`)
* **Función:** Pantallas completas armadas en Flutter (`Scaffold`).
* **Recibe:** Lee el estado de los ViewModels usando `context.watch<ViewModel>()` o `context.read<ViewModel>()`.
* **Da:** Un árbol de widgets visual que el usuario interactúa. Despacha eventos (ej. pulsar el botón reservar) hacia los ViewModels.

### `presentation/widgets/` (ej. `habitacion_card.dart`)
* **Función:** Componentes visuales pequeños y reutilizables.
* **Recibe:** Entidades u objetos específicos por constructor (ej. Recibe una `Habitacion`).
* **Da:** Un bloque de UI formateado (Tarjetas, Botones, Textos).

---

## 5. El Punto de Entrada `lib/main.dart`
* **Función:** Es el corazón configurador de la app.
  1. Inicializa Firebase.
  2. Ajusta las configuraciones de entorno (Ej. apaga la persistencia en caché local para Flutter Web con `persistenceEnabled: false` para evitar que la plataforma Web lance errores de `client is offline` con el túnel WebSocket).
  3. Lee la constante `useMocks` para decidir si conectar Firebase real o datos de prueba.
  4. **Inyección de Dependencias Manual:** Instancia los *DataSources*, se los pasa a los *Repositories*, que a su vez van a los *UseCases*, y finalmente los entrega a los *ViewModels*.
  5. Inyecta todos los ViewModels usando `MultiProvider` para que estén disponibles en toda la app.
* **Recibe:** El estado inicial del SO.
* **Da:** El árbol de widgets principal `MaterialApp`, rutas registradas y temas globales.

---

### Resumen del Flujo de una Operación (Ej. Crear Reserva)
1. **Usuario** presiona botón "Confirmar Reserva" en `ConfirmarReservaScreen`.
2. Llama a `reservaViewModel.crearReserva(fechaInicio, fechaFin, habitacion)`.
3. El ViewModel pone `isLoading = true` y llama a `crearReservaUseCase.execute(nuevaReserva)`.
4. El UseCase llama a `reservaRepository.crearReserva(nuevaReserva)`.
5. `ReservaRepositoryImpl` convierte la Entidad a `ReservaModel` y llama a `dataSource.crearReserva(reservaModel)`.
6. `ReservaDataSource` convierte el model con `.toJson()` y lo envía a Firebase Firestore.
7. Firestore responde un `OK`.
8. Todo hace el camino inverso retornando a la UI.
9. El ViewModel apaga el `isLoading`, lanza una notificación de éxito y navega a la pantalla de historial.
