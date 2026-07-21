import '../entities/resena.dart';

abstract class ResenaRepository {
  Stream<List<Resena>> getResenasPorHosteria(String hosteriaId);
  Future<void> agregarResena(Resena resena);
}
