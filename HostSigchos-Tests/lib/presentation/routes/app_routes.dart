import 'package:flutter/material.dart';

import '../views/auth/forgot_password_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/verificacion_screen.dart';
import '../views/chatbot/chatbot_screen.dart';
import '../views/chatbot/chatbot_suggestions_screen.dart';
import '../views/hosteria/hosteria_detail_screen.dart';
import '../views/hosteria/hosterias_list_screen.dart';
import '../views/landing_screen.dart';
import '../views/main/main_screen.dart';
import '../views/mapa/mapa_screen.dart';
import '../views/notificaciones/notificaciones_screen.dart';
import '../views/perfil/editar_perfil_screen.dart';
import '../views/perfil/perfil_screen.dart';
import '../views/reserva/checkout_reserva_screen.dart';
import '../views/reserva/confirmacion_reserva_screen.dart';
import '../views/reserva/crear_reserva_screen.dart';
import '../views/reserva/habitaciones_list_screen.dart';
import '../views/reserva/historial_reservas_screen.dart';
import '../views/splash_screen.dart';
import '../views/transaccion/historial_transacciones_screen.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static const String splash = '/';
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verificacion = '/verificacion';
  static const String home = '/home';
  static const String hosteriasList = '/hosterias';
  static const String hosteriaDetail = '/hosteria-detail';
  static const String habitaciones = '/habitaciones';
  static const String crearReserva = '/crear-reserva';
  static const String checkout = '/checkout-reserva';
  static const String confirmacion = '/confirmacion';

  static const String historialReservas = '/historial-reservas';
  static const String historialTransacciones = '/historial-transacciones';
  static const String mapa = '/mapa';
  static const String perfil = '/perfil';
  static const String editarPerfil = '/editar-perfil';
  static const String chatbot = '/chatbot';
  static const String chatbotSuggestions = '/chatbot-suggestions';
  static const String notificaciones = '/notificaciones';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    landing: (context) => const LandingScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    verificacion: (context) => const VerificacionScreen(),
    home: (context) => const MainScreen(),
    hosteriasList: (context) => const HosteriasListScreen(),
    hosteriaDetail: (context) => const HosteriaDetailScreen(),
    habitaciones: (context) => const HabitacionesListScreen(),
    crearReserva: (context) => const CrearReservaScreen(),
    checkout: (context) => const CheckoutReservaScreen(),
    confirmacion: (context) => const ConfirmacionReservaScreen(),
    historialReservas: (context) => const HistorialReservasScreen(),
    historialTransacciones: (context) => const HistorialTransaccionesScreen(),

    mapa: (context) => const MapaScreen(),
    notificaciones: (context) => const NotificacionesScreen(),
    perfil: (context) => const PerfilScreen(showBackButton: true),
    editarPerfil: (context) => const EditarPerfilScreen(),
    chatbot: (context) => const ChatbotScreen(),
    chatbotSuggestions: (context) {
      final suggestions = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
      return ChatbotSuggestionsScreen(suggestions: suggestions);
    },
  };
}
