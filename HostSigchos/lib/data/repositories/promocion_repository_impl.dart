import '../../domain/entities/promocion.dart';
import '../../domain/repositories/promocion_repository.dart';
import '../datasources/firebase/promocion_datasource.dart';
import '../models/promocion_model.dart';

class PromocionRepositoryImpl implements PromocionRepository {
  PromocionRepositoryImpl(this._dataSource);

  final PromocionDataSource _dataSource;

  @override
  Future<List<Promocion>> getPromociones() async {
    return _dataSource.getPromociones();
  }

  @override
  Future<Promocion> crearPromocion(Promocion promocion) async {
    final model = PromocionModel.fromEntity(promocion);
    return _dataSource.crearPromocion(model);
  }

  @override
  Future<void> actualizarPromocion(Promocion promocion) async {
    final model = PromocionModel.fromEntity(promocion);
    return _dataSource.actualizarPromocion(model);
  }
}
