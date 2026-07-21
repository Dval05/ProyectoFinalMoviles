import '../../entities/reserva.dart';
import '../../repositories/reserva_repository.dart';

class GetTodasLasReservasUseCase {
  GetTodasLasReservasUseCase(this._repository);
  final ReservaRepository _repository;

  Future<List<Reserva>> call() {
    return _repository.getTodasLasReservas();
  }
}
