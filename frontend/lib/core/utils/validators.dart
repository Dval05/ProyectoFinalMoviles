/// Validadores de formularios para la aplicación
class Validators {
  /// Valida email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  /// Valida contraseña (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida confirmación de contraseña
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida nombre (no vacío, al menos 2 caracteres)
  static String? nombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Valida teléfono ecuatoriano
  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // El teléfono es opcional
    }
    final phoneRegex = RegExp(r'^\+?593?\d{9,10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingrese un teléfono válido (ej: +593987654321)';
    }
    return null;
  }

  /// Valida cédula ecuatoriana (básico 10 dígitos)
  static String? cedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cédula es requerida';
    }
    final regex = RegExp(r'^\d{10}$');
    if (!regex.hasMatch(value.trim())) {
      return 'La cédula debe contener exactamente 10 dígitos numéricos';
    }
    return null;
  }

  /// Valida edad (mayor de edad >= 18)
  static String? edad(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La edad es requerida';
    }
    final numEdad = int.tryParse(value.trim());
    if (numEdad == null) {
      return 'Ingrese una edad numérica válida';
    }
    if (numEdad < 18) {
      return 'Debe ser mayor de 18 años para registrarse';
    }
    if (numEdad > 120) {
      return 'Ingrese una edad realista';
    }
    return null;
  }

  /// Valida que un campo no esté vacío
  static String? requerido(String? value, [String campo = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$campo es requerido';
    }
    return null;
  }

  /// Valida número de huéspedes
  static String? numHuespedes(String? value, int maxCapacidad) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el número de huéspedes';
    }
    final num = int.tryParse(value);
    if (num == null || num < 1) {
      return 'Ingrese un número válido';
    }
    if (num > maxCapacidad) {
      return 'Máximo $maxCapacidad huéspedes';
    }
    return null;
  }

  /// Valida que la fecha de checkout sea posterior al checkin
  static String? fechasReserva(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null) return 'Seleccione fecha de check-in';
    if (checkOut == null) return 'Seleccione fecha de check-out';
    if (!checkOut.isAfter(checkIn)) {
      return 'La fecha de salida debe ser posterior a la de entrada';
    }
    if (checkIn.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'La fecha de entrada no puede ser en el pasado';
    }
    return null;
  }
}
