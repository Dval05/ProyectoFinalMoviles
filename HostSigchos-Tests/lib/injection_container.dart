// Import DataSources
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
// Import Services
import 'core/services/notification_service.dart';
import 'data/datasources/api/weather_api.dart';
import 'data/datasources/firebase/auth_datasource.dart';
import 'data/datasources/firebase/habitacion_datasource.dart';
import 'data/datasources/firebase/hosteria_datasource.dart';
import 'data/datasources/firebase/notificacion_datasource.dart';

import 'data/datasources/firebase/resena_datasource.dart';
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
import 'data/repositories/notificacion_repository_impl.dart';

import 'data/repositories/resena_repository_impl.dart';
import 'data/repositories/reserva_repository_impl.dart';
// Import Domain Repositories
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chatbot_repository.dart';
import 'domain/repositories/geocoding_repository.dart';
import 'domain/repositories/habitacion_repository.dart';
import 'domain/repositories/hosteria_repository.dart';
import 'domain/repositories/notificacion_repository.dart';
import 'domain/repositories/resena_repository.dart';
import 'domain/repositories/reserva_repository.dart';
// Import UseCases
import 'domain/usecases/auth/actualizar_perfil_usecase.dart';
import 'domain/usecases/auth/eliminar_cuenta_usecase.dart';
import 'domain/usecases/auth/google_signin_usecase.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/recuperar_password_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verificar_email_usecase.dart';
import 'domain/usecases/auth/vincular_password_usecase.dart';
import 'domain/usecases/chatbot/enviar_audio_usecase.dart';
import 'domain/usecases/chatbot/enviar_mensaje_usecase.dart';
import 'domain/usecases/geocoding/get_direccion_usecase.dart';
import 'domain/usecases/habitacion/check_disponibilidad_usecase.dart';
import 'domain/usecases/habitacion/get_habitaciones_usecase.dart';
import 'domain/usecases/habitacion/get_todas_las_habitaciones_usecase.dart';
import 'domain/usecases/hosteria/get_hosteria_detail_usecase.dart';
import 'domain/usecases/hosteria/get_hosterias_usecase.dart';

import 'domain/usecases/resena/agregar_resena_usecase.dart';
import 'domain/usecases/resena/get_resenas_por_hosteria_usecase.dart';
import 'domain/usecases/reserva/actualizar_estado_reserva_usecase.dart';
import 'domain/usecases/reserva/cancelar_reserva_usecase.dart';
import 'domain/usecases/reserva/crear_reserva_usecase.dart';
import 'domain/usecases/reserva/get_historial_reservas_usecase.dart';
import 'domain/usecases/reserva/get_todas_las_reservas_usecase.dart';
// Import ViewModels
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/carrito_reserva_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/viewmodels/geocoding_viewmodel.dart';
import 'presentation/viewmodels/habitacion_viewmodel.dart';
import 'presentation/viewmodels/hosteria_viewmodel.dart';
import 'presentation/viewmodels/locale_viewmodel.dart';
import 'presentation/viewmodels/notificacion_viewmodel.dart';

import 'presentation/viewmodels/resena_viewmodel.dart';
import 'presentation/viewmodels/reserva_viewmodel.dart';
import 'presentation/viewmodels/weather_viewmodel.dart';

final GetIt getIt = GetIt.instance;
void setupLocator() {
  getIt
    // 1. Services & Core
    ..registerLazySingleton(NotificationService.new)
    // 2. DataSources
    ..registerLazySingleton(WeatherApi.new)
    ..registerLazySingleton(StorageDataSource.new)
    ..registerLazySingleton(() => AuthDataSource(getIt()))
    ..registerLazySingleton(HosteriaDataSource.new)
    ..registerLazySingleton(HabitacionDataSource.new)
    ..registerLazySingleton(ReservaDataSource.new)

    ..registerLazySingleton(GeocodingDataSource.new)
    ..registerLazySingleton(ChatbotDataSource.new)
    ..registerLazySingleton(NotificacionDataSource.new)
    ..registerLazySingleton(
      () => ResenaDataSource(
        FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'hostsigchos',
        ),
      ),
    )
    // 3. Repositories
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton<HosteriaRepository>(() => HosteriaRepositoryImpl(getIt()))
    ..registerLazySingleton<HabitacionRepository>(() => HabitacionRepositoryImpl(getIt()))
    ..registerLazySingleton<ReservaRepository>(() => ReservaRepositoryImpl(getIt()))
    ..registerLazySingleton<GeocodingRepository>(() => GeocodingRepositoryImpl(getIt()))
    ..registerLazySingleton<ChatbotRepository>(() => ChatbotRepositoryImpl(getIt()))
    ..registerLazySingleton<NotificacionRepository>(() => NotificacionRepositoryImpl(getIt()))
    ..registerLazySingleton<ResenaRepository>(() => ResenaRepositoryImpl(getIt()))
    // 4. UseCases
    // Auth
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => RegisterUseCase(getIt()))
    ..registerLazySingleton(() => GoogleSignInUseCase(getIt()))
    ..registerLazySingleton(() => LogoutUseCase(getIt()))
    ..registerLazySingleton(() => ActualizarPerfilUseCase(getIt()))
    ..registerLazySingleton(() => VincularPasswordUseCase(getIt()))
    ..registerLazySingleton(() => VerificarEmailUseCase(getIt()))
    ..registerLazySingleton(() => RecuperarPasswordUseCase(getIt()))
    ..registerLazySingleton(() => EliminarCuentaUseCase(getIt()))
    // Hosteria
    ..registerLazySingleton(() => GetHosteriasUseCase(getIt()))
    ..registerLazySingleton(() => GetHosteriaDetailUseCase(getIt()))
    // Habitacion
    ..registerLazySingleton(() => GetHabitacionesUseCase(getIt()))
    ..registerLazySingleton(() => CheckDisponibilidadUseCase(getIt()))
    ..registerLazySingleton(() => GetTodasLasHabitacionesUseCase(getIt()))
    // Reserva
    ..registerLazySingleton(() => CrearReservaUseCase(getIt()))
    ..registerLazySingleton(() => GetHistorialReservasUseCase(getIt()))
    ..registerLazySingleton(() => GetTodasLasReservasUseCase(getIt()))
    ..registerLazySingleton(() => ActualizarEstadoReservaUseCase(getIt()))
    ..registerLazySingleton(() => CancelarReservaUseCase(getIt()))

    // Geocoding
    ..registerLazySingleton(() => GetDireccionUseCase(getIt()))
    // Chatbot
    ..registerLazySingleton(() => EnviarMensajeUseCase(getIt()))
    ..registerLazySingleton(() => EnviarAudioUseCase(getIt()))
    // Resena
    ..registerLazySingleton(() => AgregarResenaUseCase(getIt()))
    ..registerLazySingleton(() => GetResenasPorHosteriaUseCase(getIt()))
    // 5. ViewModels
    ..registerFactory(LocaleViewModel.new)
    ..registerFactory(() => WeatherViewModel(getIt()))
    ..registerFactory(
      () => AuthViewModel(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        googleSignInUseCase: getIt(),
        logoutUseCase: getIt(),
        actualizarPerfilUseCase: getIt(),
        vincularPasswordUseCase: getIt(),
        verificarEmailUseCase: getIt(),
        recuperarPasswordUseCase: getIt(),
        eliminarCuentaUseCase: getIt(),
        authRepository: getIt(),
      ),
    )
    ..registerFactory(
      () => HosteriaViewModel(
        getHosteriasUseCase: getIt(),
        getHosteriaDetailUseCase: getIt(),
        getHabitacionesUseCase: getIt(),
      ),
    )
    ..registerFactory(
      () => HabitacionViewModel(
        getHabitacionesUseCase: getIt(),
        checkDisponibilidadUseCase: getIt(),
        getTodasLasHabitacionesUseCase: getIt(),
      ),
    )
    ..registerFactory(
      () => ReservaViewModel(
        crearReservaUseCase: getIt(),
        getHistorialReservasUseCase: getIt(),
        getTodasLasReservasUseCase: getIt(),
        actualizarEstadoReservaUseCase: getIt(),
        cancelarReservaUseCase: getIt(),
        checkDisponibilidadUseCase: getIt(),
      ),
    )
    ..registerFactory(CarritoReservaViewModel.new)

    ..registerFactory(() => GeocodingViewModel(getDireccionUseCase: getIt()))
    ..registerFactory(
      () => ChatbotViewModel(
        enviarMensajeUseCase: getIt(),
        enviarAudioUseCase: getIt(),
      ),
    )
    ..registerFactory(() => NotificacionViewModel(getIt()))
    ..registerFactory(
      () => ResenaViewModel(
        agregarResenaUseCase: getIt(),
        getResenasPorHosteriaUseCase: getIt(),
      ),
    );
}
