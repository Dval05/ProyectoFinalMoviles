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
    super.totalResenas,
    super.imagenes,
    super.servicios,
    super.activa,
    super.precioPorNoche,
  });

  factory HosteriaModel.fromEntity(Hosteria entity) {
    return HosteriaModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      direccion: entity.direccion,
      latitud: entity.latitud,
      longitud: entity.longitud,
      telefono: entity.telefono,
      email: entity.email,
      sitioWeb: entity.sitioWeb,
      rating: entity.rating,
      totalResenas: entity.totalResenas,
      imagenes: entity.imagenes,
      servicios: entity.servicios,
      activa: entity.activa,
      precioPorNoche: entity.precioPorNoche,
    );
  }

  factory HosteriaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
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
      totalResenas: data['totalResenas'] as int? ?? 0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      servicios: List<String>.from(data['servicios'] ?? []),
      activa: data['activa'] ?? true,
      precioPorNoche: (data['precioPorNoche'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toFirestore() {
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
      'totalResenas': totalResenas,
      'imagenes': imagenes,
      'servicios': servicios,
      'activa': activa,
      'precioPorNoche': precioPorNoche,
    };
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
