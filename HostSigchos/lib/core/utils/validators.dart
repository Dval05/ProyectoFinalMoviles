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

  /// Valida teléfono internacional
  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // El teléfono es opcional
    }
    final phoneRegex = RegExp(r'^\+?\d{9,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingrese un teléfono válido (ej: +593987654321 o 0987654321)';
    }
    return null;
  }

  /// Valida cédula ecuatoriana (Módulo 10) o Pasaporte extranjero
  static String? identificacion(String? value, String tipo) {
    if (value == null || value.trim().isEmpty) {
      return 'La identificación es requerida';
    }
    final doc = value.trim();

    if (tipo == 'Cédula') {
      if (!RegExp(r'^\d{10}$').hasMatch(doc)) {
        return 'La cédula debe tener exactamente 10 dígitos';
      }
      if (!_validarModulo10(doc)) {
        return 'Cédula ecuatoriana inválida';
      }
    } else {
      // Pasaporte
      final passportRegex = RegExp(r'^[a-zA-Z0-9]{6,20}$');
      if (!passportRegex.hasMatch(doc)) {
        return 'El pasaporte debe ser alfanumérico (6-20 caracteres)';
      }
    }

    return null;
  }

  /// Algoritmo Módulo 10 para cédulas ecuatorianas
  static bool _validarModulo10(String cedula) {
    try {
      final provincia = int.parse(cedula.substring(0, 2));
      if (provincia < 1 || provincia > 24) {
        return false;
      }

      final digitoVerificador = int.parse(cedula.substring(9, 10));
      int suma = 0;

      for (int i = 0; i < 9; i++) {
        int digito = int.parse(cedula.substring(i, i + 1));
        if (i % 2 == 0) {
          // Posiciones impares (0, 2, 4...) se multiplican por 2
          digito *= 2;
          if (digito > 9) {
            digito -= 9;
          }
        }
        suma += digito;
      }

      int decenaSuperior = ((suma ~/ 10) + 1) * 10;
      if (suma % 10 == 0) {
        decenaSuperior = suma;
      }

      final resultado = decenaSuperior - suma;
      return resultado == digitoVerificador;
    } catch (_) {
      return false;
    }
  }

  /// Valida fecha de nacimiento (mayor de edad >= 18)
  static String? fechaNacimiento(DateTime? value) {
    if (value == null) {
      return 'La fecha de nacimiento es requerida';
    }
    final hoy = DateTime.now();
    var edad = hoy.year - value.year;
    if (hoy.month < value.month ||
        (hoy.month == value.month && hoy.day < value.day)) {
      edad--;
    }
    if (edad < 18) {
      return 'Debe ser mayor de 18 años para registrarse';
    }
    if (edad > 120) {
      return 'Ingrese una fecha de nacimiento realista';
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
