import '../entities/hosteria.dart';

/// Interfaz del repositorio de hosterías
abstract class HosteriaRepository {
  /// Obtener todas las hosterías activas
  Future<List<Hosteria>> getHosterias();

  /// Obtener detalle de una hostería por ID
  Future<Hosteria> getHosteriaById(String id);

  /// Buscar hosterías por nombre
  Future<List<Hosteria>> buscarHosterias(String query);

  /// Crear una nueva hostería
  Future<void> crearHosteria(Hosteria hosteria);

  /// Actualizar una hostería existente
  Future<void> actualizarHosteria(Hosteria hosteria);
}
