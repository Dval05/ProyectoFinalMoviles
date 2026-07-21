import '../../domain/entities/hosteria.dart';
import '../../domain/repositories/hosteria_repository.dart';
import '../datasources/firebase/hosteria_datasource.dart';

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
}
