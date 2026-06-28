/// Entidad de dominio: Usuario del sistema
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fechaRegistro,
    this.cedula,
    this.fechaNacimiento,
    this.telefono,
    this.ubicacion,
    this.fotoUrl,
    this.idioma = 'es',
    this.rol = 'usuario',
  });
  final String id;
  final String nombre;
  final String email;
  final String? cedula;
  final DateTime? fechaNacimiento;
  final String? telefono;
  final String? ubicacion;
  final String? fotoUrl;
  final DateTime fechaRegistro;
  final String idioma;
  final String rol;

  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? cedula,
    DateTime? fechaNacimiento,
    String? telefono,
    String? ubicacion,
    String? fotoUrl,
    DateTime? fechaRegistro,
    String? idioma,
    String? rol,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      cedula: cedula ?? this.cedula,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      ubicacion: ubicacion ?? this.ubicacion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      idioma: idioma ?? this.idioma,
      rol: rol ?? this.rol,
    );
  }
}
