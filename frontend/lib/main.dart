import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import DataSources
import 'data/datasources/firebase/auth_datasource.dart';
import 'data/datasources/firebase/storage_datasource.dart';
import 'data/datasources/firebase/hosteria_datasource.dart';
import 'data/datasources/firebase/habitacion_datasource.dart';
import 'data/datasources/firebase/reserva_datasource.dart';
import 'data/datasources/firebase/pago_datasource.dart';
import 'data/datasources/remote/geocoding_datasource.dart';

import 'data/datasources/mock/mock_auth_datasource.dart';
import 'data/datasources/mock/mock_hosteria_datasource.dart';
import 'data/datasources/mock/mock_habitacion_datasource.dart';
import 'data/datasources/mock/mock_reserva_datasource.dart';
import 'data/datasources/mock/mock_pago_datasource.dart';



// Import Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/hosteria_repository_impl.dart';
import 'data/repositories/habitacion_repository_impl.dart';
import 'data/repositories/reserva_repository_impl.dart';
import 'data/repositories/pago_repository_impl.dart';
import 'data/repositories/geocoding_repository_impl.dart';

// Import UseCases
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/google_signin_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/hosteria/get_hosterias_usecase.dart';
import 'domain/usecases/hosteria/get_hosteria_detail_usecase.dart';
import 'domain/usecases/habitacion/get_habitaciones_usecase.dart';
import 'domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import 'domain/usecases/reserva/crear_reserva_usecase.dart';
import 'domain/usecases/reserva/get_historial_reservas_usecase.dart';
import 'domain/usecases/reserva/cancelar_reserva_usecase.dart';
import 'domain/usecases/pago/procesar_pago_usecase.dart';
import 'domain/usecases/pago/get_historial_pagos_usecase.dart';
import 'domain/usecases/geocoding/get_direccion_usecase.dart';

// Import ViewModels
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/hosteria_viewmodel.dart';
import 'presentation/viewmodels/habitacion_viewmodel.dart';
import 'presentation/viewmodels/reserva_viewmodel.dart';
import 'presentation/viewmodels/pago_viewmodel.dart';
import 'presentation/viewmodels/geocoding_viewmodel.dart';
import 'presentation/viewmodels/locale_viewmodel.dart';

// Import L10n
import 'core/l10n/app_localizations.dart';

// Import Theme & Routes
import 'themes/tema_general.dart';
import 'presentation/routes/app_routes.dart';
import 'firebase_options.dart'; // Opciones generadas por FlutterFire

const bool useMocks = false; // Cambiado a false para usar la base de datos real de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'hostsigchos').settings = const Settings(
        persistenceEnabled: false,
      );
    }
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Core ViewModels
        ChangeNotifierProvider(create: (_) => LocaleViewModel()),
        
        // Dependency Injection Manual (sin packages de DI para mantenerlo simple según Provider requirement)
        ChangeNotifierProvider(create: (_) {
          final storageDs = StorageDataSource();
          final authDs = useMocks ? MockAuthDataSource() : AuthDataSource(storageDs);
          final authRepo = AuthRepositoryImpl(authDs);
          return AuthViewModel(
            loginUseCase: LoginUseCase(authRepo),
            registerUseCase: RegisterUseCase(authRepo),
            googleSignInUseCase: GoogleSignInUseCase(authRepo),
            logoutUseCase: LogoutUseCase(authRepo),
          );
        }),
        
        ChangeNotifierProvider(create: (_) {
          final repo = HosteriaRepositoryImpl(useMocks ? MockHosteriaDataSource() : HosteriaDataSource());
          return HosteriaViewModel(
            getHosteriasUseCase: GetHosteriasUseCase(repo),
            getHosteriaDetailUseCase: GetHosteriaDetailUseCase(repo),
          );
        }),

        ChangeNotifierProvider(create: (_) {
          final repo = HabitacionRepositoryImpl(useMocks ? MockHabitacionDataSource() : HabitacionDataSource());
          return HabitacionViewModel(
            getHabitacionesUseCase: GetHabitacionesUseCase(repo),
            checkDisponibilidadUseCase: CheckDisponibilidadUseCase(repo),
          );
        }),

        ChangeNotifierProvider(create: (_) {
          final repo = ReservaRepositoryImpl(useMocks ? MockReservaDataSource() : ReservaDataSource());
          return ReservaViewModel(
            crearReservaUseCase: CrearReservaUseCase(repo),
            getHistorialReservasUseCase: GetHistorialReservasUseCase(repo),
            cancelarReservaUseCase: CancelarReservaUseCase(repo),
          );
        }),

        ChangeNotifierProvider(create: (_) {
          final repo = PagoRepositoryImpl(useMocks ? MockPagoDataSource() : PagoDataSource());
          return PagoViewModel(
            procesarPagoUseCase: ProcesarPagoUseCase(repo),
            getHistorialPagosUseCase: GetHistorialPagosUseCase(repo),
          );
        }),

        ChangeNotifierProvider(create: (_) {
          final repo = GeocodingRepositoryImpl(GeocodingDataSource());
          return GeocodingViewModel(
            getDireccionUseCase: GetDireccionUseCase(repo),
          );
        }),
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
