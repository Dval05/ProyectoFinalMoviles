import '../entities/promocion.dart';

abstract class PromocionRepository {
  Future<List<Promocion>> getPromociones();
  Future<Promocion> crearPromocion(Promocion promocion);
  Future<void> actualizarPromocion(Promocion promocion);
}
