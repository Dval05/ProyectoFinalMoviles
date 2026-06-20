import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hosteria.dart';

/// Modelo de datos: Hostería (serialización Firestore)
class HosteriaModel extends Hosteria {
  const HosteriaModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.direccion,
    required super.latitud,
    required super.longitud,
    required super.telefono,
    super.email,
    super.sitioWeb,
    super.rating,
    super.imagenes,
    super.servicios,
    super.activa,
  });

  factory HosteriaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HosteriaModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      direccion: data['direccion'] ?? '',
      latitud: (data['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (data['longitud'] as num?)?.toDouble() ?? 0.0,
      telefono: data['telefono'] ?? '',
      email: data['email'],
      sitioWeb: data['sitioWeb'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      servicios: List<String>.from(data['servicios'] ?? []),
      activa: data['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'telefono': telefono,
      'email': email,
      'sitioWeb': sitioWeb,
      'rating': rating,
      'imagenes': imagenes,
      'servicios': servicios,
      'activa': activa,
    };
  }
}
