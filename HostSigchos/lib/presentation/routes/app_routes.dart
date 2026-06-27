import 'package:flutter/material.dart';

import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/verificacion_screen.dart';
import '../views/home/home_screen.dart';
import '../views/hosteria/hosteria_detail_screen.dart';
import '../views/hosteria/hosterias_list_screen.dart';
import '../views/mapa/mapa_screen.dart';
import '../views/pago/historial_pagos_screen.dart';
import '../views/pago/pago_screen.dart';
import '../views/perfil/editar_perfil_screen.dart';
import '../views/perfil/perfil_screen.dart';
import '../views/propietario/propietario_dashboard_screen.dart';
import '../views/reserva/checkout_reserva_screen.dart';
import '../views/reserva/confirmacion_reserva_screen.dart';
import '../views/reserva/crear_reserva_screen.dart';
import '../views/reserva/habitaciones_list_screen.dart';
import '../views/reserva/historial_reservas_screen.dart';
import '../views/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verificacion = '/verificacion';
  static const String home = '/home';
  static const String hosteriasList = '/hosterias';
  static const String hosteriaDetail = '/hosteria-detail';
  static const String habitaciones = '/habitaciones';
  static const String crearReserva = '/crear-reserva';
  static const String checkout = '/checkout-reserva';
  static const String confirmacion = '/confirmacion';
  static const String pago = '/pago';
  static const String historialReservas = '/historial-reservas';
  static const String historialPagos = '/historial-pagos';
  static const String mapa = '/mapa';
  static const String perfil = '/perfil';
  static const String editarPerfil = '/editar-perfil';
  static const String propietarioDashboard = '/propietario-dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    verificacion: (context) => const VerificacionScreen(),
    home: (context) => const HomeScreen(),
    hosteriasList: (context) => const HosteriasListScreen(),
    hosteriaDetail: (context) => const HosteriaDetailScreen(),
    habitaciones: (context) => const HabitacionesListScreen(),
    crearReserva: (context) => const CrearReservaScreen(),
    checkout: (context) => const CheckoutReservaScreen(),
    confirmacion: (context) => const ConfirmacionReservaScreen(),
    historialReservas: (context) => const HistorialReservasScreen(),
    historialPagos: (context) => const HistorialPagosScreen(),
    pago: (context) => const PagoScreen(),
    mapa: (context) => const MapaScreen(),
    perfil: (context) => const PerfilScreen(),
    editarPerfil: (context) => const EditarPerfilScreen(),
    propietarioDashboard: (context) => const PropietarioDashboardScreen(),
  };
}
