import '../../models/hosteria_model.dart';
import '../firebase/hosteria_datasource.dart';

class MockHosteriaDataSource implements HosteriaDataSource {
  final List<HosteriaModel> mockHosterias = [
    const HosteriaModel(
      id: 'h1',
      nombre: 'Hostería San José',
      descripcion: 'Hermosa hostería en el corazón de Sigchos, con vistas al volcán y áreas verdes.',
      direccion: 'Centro de Sigchos',
      latitud: -0.7025,
      longitud: -78.8821,
      telefono: '0987654321',
      email: 'contacto@sanjose.com',
      rating: 4.8,
      imagenes: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      ],
      servicios: ['WiFi', 'Piscina', 'Desayuno Incluido', 'Parqueadero'],
      activa: true,
    ),
    const HosteriaModel(
      id: 'h2',
      nombre: 'Quinta Samil',
      descripcion: 'Lugar de descanso con cabañas rústicas y comida típica.',
      direccion: 'Afueras de Sigchos',
      latitud: -0.7100,
      longitud: -78.8900,
      telefono: '0999999999',
      rating: 4.5,
      imagenes: [
        'https://images.unsplash.com/photo-1542314831-c6a4d27d6681?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      ],
      servicios: ['Restaurante', 'Senderos', 'Pet Friendly'],
      activa: true,
    ),
  ];

  @override
  Future<List<HosteriaModel>> getHosterias() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula red
    return mockHosterias.where((h) => h.activa).toList();
  }

  @override
  Future<HosteriaModel> getHosteriaById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockHosterias.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('Hostería no encontrada'),
    );
  }

  @override
  Future<List<HosteriaModel>> buscarHosterias(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lowerQuery = query.toLowerCase();
    return mockHosterias.where((h) =>
        h.activa &&
        (h.nombre.toLowerCase().contains(lowerQuery) ||
         h.descripcion.toLowerCase().contains(lowerQuery))).toList();
  }
}
