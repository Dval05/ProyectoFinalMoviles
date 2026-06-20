import '../../models/habitacion_model.dart';
import '../firebase/habitacion_datasource.dart';

class MockHabitacionDataSource implements HabitacionDataSource {
  final List<HabitacionModel> mockHabitaciones = [
    const HabitacionModel(
      id: 'hab1',
      hosteriaId: 'h1',
      tipo: 'Matrimonial',
      descripcion: 'Cama de 2 plazas, baño privado y balcón.',
      capacidad: 2,
      precioPorNoche: 45.0,
      imagenes: [
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
      ],
      amenidades: ['TV', 'Agua Caliente', 'WiFi'],
      disponible: true,
    ),
    const HabitacionModel(
      id: 'hab2',
      hosteriaId: 'h1',
      tipo: 'Familiar',
      descripcion: 'Dos camas de 2 plazas y una litera.',
      capacidad: 6,
      precioPorNoche: 80.0,
      imagenes: [
        'https://images.unsplash.com/photo-1566665797739-1674de7a421a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
      ],
      amenidades: ['TV', 'Agua Caliente', 'Mini bar'],
      disponible: true,
    ),
    const HabitacionModel(
      id: 'hab3',
      hosteriaId: 'h2',
      tipo: 'Cabaña Rústica',
      descripcion: 'Hermosa cabaña independiente con chimenea.',
      capacidad: 4,
      precioPorNoche: 60.0,
      imagenes: [
        'https://images.unsplash.com/photo-1521401830884-6c03c1c87ebb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
      ],
      amenidades: ['Chimenea', 'Naturaleza'],
      disponible: true,
    ),
  ];

  @override
  Future<List<HabitacionModel>> getHabitacionesPorHosteria(String hosteriaId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockHabitaciones.where((h) => h.hosteriaId == hosteriaId).toList();
  }

  @override
  Future<HabitacionModel> getHabitacionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockHabitaciones.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('Habitación no encontrada'),
    );
  }

  @override
  Future<bool> verificarDisponibilidad(String habitacionId, DateTime checkIn, DateTime checkOut) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final hab = await getHabitacionById(habitacionId);
    return hab.disponible;
  }
}
