// Justificación: Se ignoran imports no usados generados por mocks
// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/datasources/firebase/auth_datasource.dart';
import 'package:frontend/data/models/usuario_model.dart';
import 'package:frontend/data/repositories/auth_repository_impl.dart';
import 'package:frontend/domain/entities/usuario.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AuthDataSource])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  final testUser = UsuarioModel(
    id: '123',
    nombre: 'Prueba',
    email: 'test@hostsigchos.com',
    cedula: '1234567890',
    fechaRegistro: DateTime(2023),
  );

  test('loginConEmail debe retornar un Usuario y llamar al dataSource', () async {
    // Arrange
    when(mockDataSource.loginConEmail('test@hostsigchos.com', '123456'))
        .thenAnswer((_) async => testUser);

    // Act
    final result = await repository.loginConEmail('test@hostsigchos.com', '123456');

    // Assert
    expect(result.id, '123');
    expect(result.email, 'test@hostsigchos.com');
    verify(mockDataSource.loginConEmail('test@hostsigchos.com', '123456')).called(1);
  });

  test('cerrarSesion debe delegar al dataSource', () async {
    // Arrange
    when(mockDataSource.cerrarSesion()).thenAnswer((_) async => {});

    // Act
    await repository.cerrarSesion();

    // Assert
    verify(mockDataSource.cerrarSesion()).called(1);
  });
}
