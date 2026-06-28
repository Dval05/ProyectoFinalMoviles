import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Import L10n
import 'core/l10n/app_localizations.dart';
// Import Services
import 'core/services/notification_service.dart';
import 'data/datasources/api/weather_api.dart';
// Import DataSources
import 'data/datasources/firebase/auth_datasource.dart';
import 'data/datasources/firebase/habitacion_datasource.dart';
import 'data/datasources/firebase/hosteria_datasource.dart';
import 'data/datasources/firebase/pago_datasource.dart';
import 'data/datasources/firebase/promocion_datasource.dart';
import 'data/datasources/firebase/reserva_datasource.dart';
import 'data/datasources/firebase/storage_datasource.dart';
import 'data/datasources/remote/chatbot_datasource.dart';
import 'data/datasources/remote/geocoding_datasource.dart';
// Import Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chatbot_repository_impl.dart';
import 'data/repositories/geocoding_repository_impl.dart';
import 'data/repositories/habitacion_repository_impl.dart';
import 'data/repositories/hosteria_repository_impl.dart';
import 'data/repositories/pago_repository_impl.dart';
import 'data/repositories/promocion_repository_impl.dart';
import 'data/repositories/reserva_repository_impl.dart';
import 'domain/usecases/auth/actualizar_perfil_usecase.dart';
import 'domain/usecases/auth/google_signin_usecase.dart';
// Import UseCases
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verificar_email_usecase.dart';
import 'domain/usecases/auth/verificar_telefono_usecase.dart';
import 'domain/usecases/auth/vincular_password_usecase.dart';
import 'domain/usecases/chatbot/enviar_audio_usecase.dart';
import 'domain/usecases/chatbot/enviar_mensaje_usecase.dart';
import 'domain/usecases/geocoding/get_direccion_usecase.dart';
import 'domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import 'domain/usecases/habitacion/get_habitaciones_usecase.dart';
import 'domain/usecases/hosteria/actualizar_hosteria_usecase.dart';
import 'domain/usecases/hosteria/crear_hosteria_usecase.dart';
import 'domain/usecases/hosteria/get_hosteria_detail_usecase.dart';
import 'domain/usecases/hosteria/get_hosterias_usecase.dart';
import 'domain/usecases/pago/actualizar_estado_pago_usecase.dart';
import 'domain/usecases/pago/get_historial_pagos_usecase.dart';
import 'domain/usecases/pago/procesar_pago_usecase.dart';
import 'domain/usecases/promocion/actualizar_promocion_usecase.dart';
import 'domain/usecases/promocion/crear_promocion_usecase.dart';
import 'domain/usecases/promocion/get_promociones_usecase.dart';
import 'domain/usecases/reserva/actualizar_estado_reserva_usecase.dart';
import 'domain/usecases/reserva/cancelar_reserva_usecase.dart';
import 'domain/usecases/reserva/crear_reserva_usecase.dart';
import 'domain/usecases/reserva/get_historial_reservas_usecase.dart';
import 'domain/usecases/reserva/get_todas_las_reservas_usecase.dart';
import 'firebase_options.dart'; // Opciones generadas por FlutterFire
import 'presentation/routes/app_routes.dart';
// Import ViewModels
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/carrito_reserva_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/viewmodels/geocoding_viewmodel.dart';
import 'presentation/viewmodels/habitacion_viewmodel.dart';
import 'presentation/viewmodels/hosteria_viewmodel.dart';
import 'presentation/viewmodels/locale_viewmodel.dart';
import 'presentation/viewmodels/pago_viewmodel.dart';
import 'presentation/viewmodels/promocion_viewmodel.dart';
import 'presentation/viewmodels/reserva_viewmodel.dart';
import 'presentation/viewmodels/weather_viewmodel.dart';
// Import Theme & Routes
import 'themes/tema_general.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicialización de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'hostsigchos',
      ).settings = const Settings(
        persistenceEnabled: false,
      );
    }
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
  }

  // Inicializar servicio de notificaciones
  try {
    await NotificationService().inicializar();
  } catch (e) {
    debugPrint('Error inicializando notificaciones: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Core ViewModels
        ChangeNotifierProvider(create: (_) => LocaleViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel(WeatherApi())),

        // Dependency Injection Manual (sin packages de DI para mantenerlo simple según Provider requirement)
        ChangeNotifierProvider(
          create: (_) {
            final storageDs = StorageDataSource();
            final authDs = AuthDataSource(storageDs);
            final authRepo = AuthRepositoryImpl(authDs);
            return AuthViewModel(
              loginUseCase: LoginUseCase(authRepo),
              registerUseCase: RegisterUseCase(authRepo),
              googleSignInUseCase: GoogleSignInUseCase(authRepo),
              logoutUseCase: LogoutUseCase(authRepo),
              actualizarPerfilUseCase: ActualizarPerfilUseCase(authRepo),
              vincularPasswordUseCase: VincularPasswordUseCase(authRepo),
              verificarEmailUseCase: VerificarEmailUseCase(authRepo),
              verificarTelefonoUseCase: VerificarTelefonoUseCase(authRepo),
              authRepository: authRepo,
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = HosteriaRepositoryImpl(HosteriaDataSource());
            return HosteriaViewModel(
              getHosteriasUseCase: GetHosteriasUseCase(repo),
              getHosteriaDetailUseCase: GetHosteriaDetailUseCase(repo),
              crearHosteriaUseCase: CrearHosteriaUseCase(repo),
              actualizarHosteriaUseCase: ActualizarHosteriaUseCase(repo),
              getHabitacionesUseCase: GetHabitacionesUseCase(
                HabitacionRepositoryImpl(HabitacionDataSource()),
              ),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = HabitacionRepositoryImpl(HabitacionDataSource());
            return HabitacionViewModel(
              getHabitacionesUseCase: GetHabitacionesUseCase(repo),
              checkDisponibilidadUseCase: CheckDisponibilidadUseCase(repo),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repoReserva = ReservaRepositoryImpl(ReservaDataSource());
            final repoHabitacion = HabitacionRepositoryImpl(
              HabitacionDataSource(),
            );
            return ReservaViewModel(
              crearReservaUseCase: CrearReservaUseCase(repoReserva),
              getHistorialReservasUseCase: GetHistorialReservasUseCase(
                repoReserva,
              ),
              getTodasLasReservasUseCase: GetTodasLasReservasUseCase(
                repoReserva,
              ),
              actualizarEstadoReservaUseCase: ActualizarEstadoReservaUseCase(
                repoReserva,
              ),
              cancelarReservaUseCase: CancelarReservaUseCase(repoReserva),
              checkDisponibilidadUseCase: CheckDisponibilidadUseCase(
                repoHabitacion,
              ),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) => CarritoReservaViewModel(),
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = PromocionRepositoryImpl(PromocionDataSource());
            return PromocionViewModel(
              getPromocionesUseCase: GetPromocionesUseCase(repo),
              crearPromocionUseCase: CrearPromocionUseCase(repo),
              actualizarPromocionUseCase: ActualizarPromocionUseCase(repo),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = PagoRepositoryImpl(PagoDataSource());
            final reservaRepo = ReservaRepositoryImpl(ReservaDataSource());
            return PagoViewModel(
              procesarPagoUseCase: ProcesarPagoUseCase(repo, reservaRepo),
              getHistorialPagosUseCase: GetHistorialPagosUseCase(repo),
              actualizarEstadoPagoUseCase: ActualizarEstadoPagoUseCase(
                repo,
                reservaRepo,
              ),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = GeocodingRepositoryImpl(GeocodingDataSource());
            return GeocodingViewModel(
              getDireccionUseCase: GetDireccionUseCase(repo),
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final repo = ChatbotRepositoryImpl(ChatbotDataSource());
            return ChatbotViewModel(
              enviarMensajeUseCase: EnviarMensajeUseCase(repo),
              enviarAudioUseCase: EnviarAudioUseCase(repo),
            );
          },
        ),
      ],
      child: const HostSigchosApp(),
    ),
  );
}

class HostSigchosApp extends StatelessWidget {
  const HostSigchosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeVm = context.watch<LocaleViewModel>();

    return MaterialApp(
      title: 'HostSigchos',
      debugShowCheckedModeBanner: false,
      theme: GeneralThemeApp.theme,

      // Internacionalización
      locale: localeVm.locale,
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Rutas
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
