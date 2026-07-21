# HostSigchos - Pruebas Unitarias

Esta carpeta contiene la implementación de pruebas unitarias reales utilizando `flutter_test` y `mockito`, validadas para el informe final de HostSigchos.

## Estructura de pruebas agregadas

- `test/domain/entities/reserva_test.dart`: Prueba los cálculos de fechas y cambios de estado.
- `test/domain/usecases/reserva/verificar_disponibilidad_usecase_test.dart`: Prueba la lógica de negocio para evitar el Overbooking usando clases Mock.
- `test/domain/usecases/reserva/crear_reserva_usecase_test.dart`: Prueba la propagación del flujo de reservas y manejo de errores.

## Ejecución
Para correr las pruebas, dentro de este directorio ejecute:
```bash
flutter test
```
