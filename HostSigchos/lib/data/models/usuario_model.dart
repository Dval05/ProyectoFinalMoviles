import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/usuario.dart';

/// Modelo de datos: Usuario (serialización Firestore)
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    required super.fechaRegistro,
    super.cedula,
    super.fechaNacimiento,
    super.telefono,
    super.ubicacion,
    super.fotoUrl,
    super.idioma,
  });

  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return UsuarioModel(
      id: doc.id,
      nombre: (data['nombre'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      cedula: data['cedula'] as String?,
      fechaNacimiento: (data['fechaNacimiento'] as Timestamp?)?.toDate(),
      telefono: data['telefono'] as String?,
      ubicacion: data['ubicacion'] as String?,
      fotoUrl: data['fotoUrl'] as String?,
      fechaRegistro:
          (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      idioma: (data['idioma'] as String?) ?? 'es',
    );
  }

  factory UsuarioModel.fromEntity(Usuario entity) {
    return UsuarioModel(
      id: entity.id,
      nombre: entity.nombre,
      email: entity.email,
      cedula: entity.cedula,
      fechaNacimiento: entity.fechaNacimiento,
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
      if (fechaNacimiento != null)
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento!),
      'telefono': telefono,
      'ubicacion': ubicacion,
      'fotoUrl': fotoUrl,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'idioma': idioma,
    };
  }
}
