import '../../domain/entities/resena.dart';
import '../../domain/repositories/resena_repository.dart';
import '../datasources/firebase/resena_datasource.dart';
import '../models/resena_model.dart';

class ResenaRepositoryImpl implements ResenaRepository {
  const ResenaRepositoryImpl(this._dataSource);
  final ResenaDataSource _dataSource;

  @override
  Stream<List<Resena>> getResenasPorHosteria(String hosteriaId) {
    return _dataSource.getResenasPorHosteria(hosteriaId);
  }

  @override
  Future<void> agregarResena(Resena resena) async {
    final model = ResenaModel.fromEntity(resena);
    await _dataSource.agregarResena(model);
  }
}
