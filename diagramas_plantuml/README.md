# 📊 Diagramas PlantUML — HostSigchos

Este directorio contiene **todos los diagramas UML del proyecto HostSigchos** en formato PlantUML (`.puml`).

Están organizados en tres carpetas principales según su área de impacto:
- **📁 movil/**: Diagramas específicos de la aplicación móvil en Flutter (Turistas).
- **📁 web/**: Diagramas específicos del panel web en React (Propietarios y Administradores).
- **📁 general/**: Diagramas de arquitectura global, despliegue y bases de datos que aplican a todo el ecosistema.

> **Nota sobre sintaxis:** Se omitió la instrucción `!theme plain` para asegurar compatibilidad con versiones antiguas del renderizador de PlantUML.

## 🛠️ Cómo Renderizar

1. **VS Code:** Instalar la extensión [PlantUML](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) → `Alt+D` para previsualizar.
2. **Online:** Copiar el contenido en [PlantUML Web Server](https://www.plantuml.com/plantuml/uml/).
3. **CLI:** `java -jar plantuml.jar archivo.puml` (genera `.png` o `.svg`).

---

## 📂 Índice de Diagramas

### 📁 general/ (Arquitectura y Modelos)
| Archivo | Descripción |
|---------|-------------|
| `01_arquitectura_componentes.puml` | Diagrama de componentes del sistema completo (Móvil + Web + Firebase) |
| `03_despliegue.puml` | Diagrama de despliegue: infraestructura y nodos |
| `08_caso_uso_general.puml` | Diagrama general con TODOS los actores y casos de uso |
| `33_modelo_datos_er.puml` | Diagrama Entidad-Relación de colecciones de Firestore |

### 📁 movil/ (App Flutter)
| Archivo | Descripción |
|---------|-------------|
| `02_paquetes_clean_architecture.puml` | Capas de Clean Architecture en Flutter |
| `04_puente_repository_pattern.puml` | Patrón Bridge/Repository |
| `05_caso_uso_turista.puml` | Casos de uso del actor Turista |
| `09_clases_entidades_dominio.puml` | Clases de la capa Domain (Entities) |
| `10_clases_repositories.puml` | Interfaces de Repository + Implementaciones |
| `11_clases_usecases.puml` | Todos los casos de uso por módulo |
| `12_clases_viewmodels.puml` | ViewModels de la capa Presentation |
| `13_clases_datasources.puml` | DataSources y Models de la capa Data |
| `15_secuencia_arranque.puml` | Flujo de inicialización de la app |
| `16_secuencia_login_email.puml` | Login con email y contraseña |
| `17_secuencia_registro.puml` | Registro de usuario nuevo |
| `18_secuencia_google_signin.puml` | Login con Google Sign-In |
| `19_secuencia_biometria.puml` | Login con huella/Face ID |
| `20_secuencia_reserva_completa.puml` | Flujo completo de reserva (crear → checkout → confirmar) |
| `21_secuencia_cancelacion.puml` | Cancelación manual + auto-cancelación 48h |
| `22_secuencia_notificaciones.puml` | Sistema de notificaciones en tiempo real |
| `23_secuencia_chatbot.puml` | Chatbot IA: texto y audio |
| `24_secuencia_resenas.puml` | Reseñas en tiempo real |
| `28_estados_reserva.puml` | Ciclo de vida de una reserva (5 estados) |
| `29_estados_sesion_usuario.puml` | Estados de sesión del usuario |
| `30_actividad_flujo_reserva.puml` | Proceso completo de reserva paso a paso |
| `31_actividad_autenticacion.puml` | Proceso de decisión de autenticación |
| `32_actividad_verificar_disponibilidad.puml` | Verificación de disponibilidad de habitaciones |

### 📁 web/ (Panel React)
| Archivo | Descripción |
|---------|-------------|
| `06_caso_uso_propietario.puml` | Casos de uso del actor Propietario (panel web) |
| `07_caso_uso_administrador.puml` | Casos de uso del actor Administrador del Sistema |
| `14_clases_web_context.puml` | Estructura del AppContext del panel web React |
| `25_secuencia_web_login.puml` | Login del panel web (propietario/admin) |
| `26_secuencia_web_reservas.puml` | Gestión de reservas del propietario |
| `27_secuencia_promociones.puml` | Creación y eliminación de promociones |
