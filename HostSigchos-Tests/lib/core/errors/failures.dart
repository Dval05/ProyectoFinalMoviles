/// Clases de error para manejo de fallos en la aplicación
abstract class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

class FirestoreFailure extends Failure {
  const FirestoreFailure([
    super.message = 'Error al acceder a la base de datos',
  ]);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Error al subir el archivo']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}
