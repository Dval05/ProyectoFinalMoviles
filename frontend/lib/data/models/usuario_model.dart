import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/usuario.dart';

/// Modelo de datos: Usuario (serialización Firestore)
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    super.cedula,
    super.edad,
    super.telefono,
    super.ubicacion,
    super.fotoUrl,
    required super.fechaRegistro,
    super.idioma,
  });

  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      cedula: data['cedula'],
      edad: data['edad'],
      telefono: data['telefono'],
      ubicacion: data['ubicacion'],
      fotoUrl: data['fotoUrl'],
      fechaRegistro: (data['fechaRegistro'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      idioma: data['idioma'] ?? 'es',
    );
  }

  factory UsuarioModel.fromEntity(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      nombre: entity.nombre,
      email: entity.email,
      cedula: entity.cedula,
      edad: entity.edad,
      telefono: entity.telefono,
      ubicacion: entity.ubicacion,
      fotoUrl: entity.fotoUrl,
      fechaRegistro: entity.fechaRegistro,
      idioma: entity.idioma,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'cedula': cedula,
      'edad': edad,
      'telefono': telefono,
      'ubicacion': ubicacion,
      'fotoUrl': fotoUrl,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'idioma': idioma,
    };
  }
}
