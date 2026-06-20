/// Entidad de dominio: Usuario del sistema
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? cedula;
  final int? edad;
  final String? telefono;
  final String? ubicacion;
  final String? fotoUrl;
  final DateTime fechaRegistro;
  final String idioma;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.cedula,
    this.edad,
    this.telefono,
    this.ubicacion,
    this.fotoUrl,
    required this.fechaRegistro,
    this.idioma = 'es',
  });

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? cedula,
    int? edad,
    String? telefono,
    String? ubicacion,
    String? fotoUrl,
    DateTime? fechaRegistro,
    String? idioma,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      cedula: cedula ?? this.cedula,
      edad: edad ?? this.edad,
      telefono: telefono ?? this.telefono,
      ubicacion: ubicacion ?? this.ubicacion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idioma: idioma ?? this.idioma,
    );
  }
}
