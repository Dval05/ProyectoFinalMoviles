import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

import '../errors/failures.dart';

class ErrorHandler {
  static String getFriendlyMessage(dynamic error) {
    final isSpanish = _isSpanish();

    if (error == null) {
      return isSpanish
          ? 'Error desconocido. Inténtalo más tarde.'
          : 'Unknown error. Please try again later.';
    }

    if (error is Failure) {
      return error.message;
    }

    final String eString = error.toString().toLowerCase();

    // Mapping Firebase Auth error codes
    if (eString.contains('user-not-found')) {
      return isSpanish
          ? 'No existe un usuario con este correo electrónico.'
          : 'No user found with this email.';
    }
    if (eString.contains('wrong-password') ||
        eString.contains('invalid-credential')) {
      return isSpanish
          ? 'Correo o contraseña incorrectos.'
          : 'Incorrect email or password.';
    }
    if (eString.contains('email-already-in-use')) {
      return isSpanish
          ? 'Este correo ya está registrado en otra cuenta.'
          : 'This email is already registered to another account.';
    }
    if (eString.contains('invalid-email')) {
      return isSpanish
          ? 'El formato del correo es inválido.'
          : 'Invalid email format.';
    }
    if (eString.contains('user-disabled')) {
      return isSpanish
          ? 'Esta cuenta ha sido deshabilitada.'
          : 'This account has been disabled.';
    }
    if (eString.contains('network-request-failed') ||
        eString.contains('socketexception')) {
      return isSpanish
          ? 'Problema de conexión. Verifica tu internet e inténtalo de nuevo.'
          : 'Network issue. Please check your internet connection and try again.';
    }
    if (eString.contains('invalid-verification-code')) {
      return isSpanish
          ? 'El código de verificación ingresado es incorrecto.'
          : 'The verification code entered is incorrect.';
    }
    if (eString.contains('provider-already-linked')) {
      return isSpanish
          ? 'La cuenta ya está vinculada a otro proveedor.'
          : 'The account is already linked to another provider.';
    }
    if (eString.contains('operation-not-allowed')) {
      return isSpanish
          ? 'La verificación por SMS u otro método no está habilitada en estos momentos. Por favor, inténtalo más tarde.'
          : 'This verification method is currently not enabled on the server. Please try again later.';
    }
    if (eString.contains('too-many-requests')) {
      return isSpanish
          ? 'Demasiados intentos. Por favor, inténtalo más tarde.'
          : 'Too many attempts. Please try again later.';
    }

    // Google Sign-In errors
    if (eString.contains('account reauth failed') ||
        eString.contains('sign_in_failed') ||
        eString.contains('googlesigninexception')) {
      return isSpanish
          ? 'No se pudo iniciar sesión con Google. Verifica tu conexión e inténtalo de nuevo.'
          : 'Could not sign in with Google. Check your connection and try again.';
    }
    if (eString.contains('canceled') || eString.contains('cancelled')) {
      return isSpanish
          ? 'Inicio de sesión cancelado.'
          : 'Sign-in was cancelled.';
    }

    // Fallback genérico para no exponer errores crudos
    debugPrint('Excepción no mapeada capturada: $error');
    return isSpanish
        ? 'Se ha producido un error interno. Inténtalo en unos minutos.'
        : 'An internal error occurred. Please try again in a few minutes.';
  }

  static bool _isSpanish() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      return locale.languageCode == 'es';
    } catch (_) {
      return true; // Por defecto Español para esta app
    }
  }
}
