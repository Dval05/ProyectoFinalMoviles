import '../../domain/entities/hosteria.dart';
import '../../domain/repositories/hosteria_repository.dart';
import '../datasources/firebase/hosteria_datasource.dart';

class HosteriaRepositoryImpl implements HosteriaRepository {
  final HosteriaDataSource _dataSource;

  HosteriaRepositoryImpl(this._dataSource);

  @override
  Future<List<Hosteria>> getHosterias() async {
    return await _dataSource.getHosterias();
  }

  @override
  Future<Hosteria> getHosteriaById(String id) async {
    return await _dataSource.getHosteriaById(id);
  }

  @override
  Future<List<Hosteria>> buscarHosterias(String query) async {
    return await _dataSource.buscarHosterias(query);
  }
}
