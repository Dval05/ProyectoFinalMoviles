# HostSigchos - Sistema de Reservas Turísticas 🏔️

Bienvenido al repositorio central de **HostSigchos**, un ecosistema tecnológico integral diseñado para modernizar y gestionar las reservas de hosterías en el cantón Sigchos, provincia de Cotopaxi.

Este repositorio actúa como el monorepo ("Monorepository") del proyecto, conteniendo múltiples sub-proyectos, documentación técnica e infraestructura en distintas carpetas.

## 🗂️ Estructura General del Proyecto

A continuación, se detalla la función de cada directorio principal:

### 📱 1. `HostSigchos/` (Aplicación Móvil Principal)
Esta es la carpeta más crítica del ecosistema móvil. Contiene el código fuente de la aplicación móvil desarrollada en **Flutter** utilizando los principios de **Clean Architecture** y el patrón **MVVM**.
* **Propósito:** Brindar al turista una aplicación intuitiva para explorar hosterías, hablar con un asistente IA (Gemini), visualizar mapas integrados y crear reservaciones.
* **Nota:** Esta carpeta incluye la suite **completa** de pruebas (Unitarias, de Interfaz y End-to-End con Appium), por lo que es la versión certificada para producción.
* 📖 [Leer la documentación detallada del aplicativo móvil](./HostSigchos/README.md)

### 💻 2. `HostSigchos-Web/` (Panel Administrativo Web)
Contiene el código fuente de la plataforma administrativa desarrollada en **React.js**.
* **Propósito:** Permitir a los dueños de las hosterías ingresar de forma segura para aprobar, rechazar o monitorear las reservas que hacen los turistas desde la aplicación móvil. Funciona de manera síncrona en tiempo real gracias a Firebase.

### 📝 3. `informes_latex/` (Documentación Formal)
Contiene los archivos `.tex`, bibliografías (`.bib`) y assets de imágenes necesarios para compilar los informes formales universitarios.
* **Propósito:** Generar reportes técnicos (como el *Informe 3.2* y el *Informe Final*) con el más alto estándar de formateo académico.
* 📖 [Leer la documentación para compilar LaTeX](./informes_latex/README.md)

### 📊 4. `diagramas_plantuml/` (Diseño del Sistema)
Almacena todos los diagramas estructurales (UML, Casos de Uso, Entidad-Relación) en formato como código (PlantUML).
* **Propósito:** Documentar la arquitectura de manera visual, lo cual permite actualizar el diseño escribiendo código en lugar de dibujar gráficos estáticos.

---

## 🚀 ¿Por dónde empezar?
Si eres un desarrollador nuevo en este repositorio y quieres correr la aplicación móvil en tu emulador local, navega a la carpeta principal de Flutter:
```bash
cd HostSigchos-Tests
flutter pub get
flutter run
```

> **Importante:** La aplicación móvil necesita las variables de entorno para funcionar y autenticarse con Firebase y Gemini. Asegúrate de que exista tu archivo `.env` localmente tal y como se documenta en los manuales internos.
