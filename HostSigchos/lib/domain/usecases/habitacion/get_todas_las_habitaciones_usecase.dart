import '../../entities/habitacion.dart';
import '../../repositories/habitacion_repository.dart';

class GetTodasLasHabitacionesUseCase {
  GetTodasLasHabitacionesUseCase(this.repository);

  final HabitacionRepository repository;

  Future<List<Habitacion>> call() async {
    return repository.getTodasLasHabitaciones();
  }
}
