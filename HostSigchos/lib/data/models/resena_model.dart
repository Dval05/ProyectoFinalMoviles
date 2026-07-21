import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/resena.dart';

class ResenaModel extends Resena {
  const ResenaModel({
    required super.id,
    required super.hosteriaId,
    required super.usuarioId,
    required super.nombreUsuario,
    required super.comentario,
    required super.rating,
    required super.fecha,
  });

  factory ResenaModel.fromEntity(Resena entity) {
    return ResenaModel(
      id: entity.id,
      hosteriaId: entity.hosteriaId,
      usuarioId: entity.usuarioId,
      nombreUsuario: entity.nombreUsuario,
      comentario: entity.comentario,
      rating: entity.rating,
      fecha: entity.fecha,
    );
  }

  factory ResenaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ResenaModel(
      id: doc.id,
      hosteriaId: data['hosteriaId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? 'Usuario',
      comentario: data['comentario'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hosteriaId': hosteriaId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'comentario': comentario,
      'rating': rating,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
