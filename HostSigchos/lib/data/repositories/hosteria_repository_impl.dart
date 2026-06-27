import '../../domain/entities/hosteria.dart';
import '../../domain/repositories/hosteria_repository.dart';
import '../datasources/firebase/hosteria_datasource.dart';
import '../models/hosteria_model.dart';

class HosteriaRepositoryImpl implements HosteriaRepository {

  HosteriaRepositoryImpl(this._dataSource);
  final HosteriaDataSource _dataSource;

  @override
  Future<List<Hosteria>> getHosterias() async {
    return _dataSource.getHosterias();
  }

  @override
  Future<Hosteria> getHosteriaById(String id) async {
    return _dataSource.getHosteriaById(id);
  }

  @override
  Future<List<Hosteria>> buscarHosterias(String query) async {
    return _dataSource.buscarHosterias(query);
  }

  @override
  Future<void> crearHosteria(Hosteria hosteria) async {
    final model = HosteriaModel.fromEntity(hosteria);
    return _dataSource.crearHosteria(model);
  }

  @override
  Future<void> actualizarHosteria(Hosteria hosteria) async {
    final model = HosteriaModel.fromEntity(hosteria);
    return _dataSource.actualizarHosteria(model);
  }
}
