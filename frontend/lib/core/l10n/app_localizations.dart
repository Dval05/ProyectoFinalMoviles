import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'HostSigchos'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Reservas en Sigchos'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get hasAccount;

  /// No description provided for @signInWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get signInWithGoogle;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @hosterias.
  ///
  /// In es, this message translates to:
  /// **'Hosterías'**
  String get hosterias;

  /// No description provided for @reservations.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get reservations;

  /// No description provided for @map.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @searchHosterias.
  ///
  /// In es, this message translates to:
  /// **'Buscar hosterías...'**
  String get searchHosterias;

  /// No description provided for @rooms.
  ///
  /// In es, this message translates to:
  /// **'Habitaciones'**
  String get rooms;

  /// No description provided for @services.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get services;

  /// No description provided for @location.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// No description provided for @contact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contact;

  /// No description provided for @photos.
  ///
  /// In es, this message translates to:
  /// **'Fotografías'**
  String get photos;

  /// No description provided for @availability.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad'**
  String get availability;

  /// No description provided for @roomType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de habitación'**
  String get roomType;

  /// No description provided for @pricePerNight.
  ///
  /// In es, this message translates to:
  /// **'Precio por noche'**
  String get pricePerNight;

  /// No description provided for @guests.
  ///
  /// In es, this message translates to:
  /// **'Huéspedes'**
  String get guests;

  /// No description provided for @checkIn.
  ///
  /// In es, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In es, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// No description provided for @nights.
  ///
  /// In es, this message translates to:
  /// **'noches'**
  String get nights;

  /// No description provided for @night.
  ///
  /// In es, this message translates to:
  /// **'noche'**
  String get night;

  /// No description provided for @totalPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio total'**
  String get totalPrice;

  /// No description provided for @bookNow.
  ///
  /// In es, this message translates to:
  /// **'Reservar ahora'**
  String get bookNow;

  /// No description provided for @confirmReservation.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get confirmReservation;

  /// No description provided for @cancelReservation.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelReservation;

  /// No description provided for @reservationHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de reservas'**
  String get reservationHistory;

  /// No description provided for @payment.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get payment;

  /// No description provided for @paymentHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de pagos'**
  String get paymentHistory;

  /// No description provided for @payNow.
  ///
  /// In es, this message translates to:
  /// **'Pagar ahora'**
  String get payNow;

  /// No description provided for @cardNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de expiración'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In es, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardHolder.
  ///
  /// In es, this message translates to:
  /// **'Titular de la tarjeta'**
  String get cardHolder;

  /// No description provided for @confirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get cancelled;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completed;

  /// No description provided for @noReservations.
  ///
  /// In es, this message translates to:
  /// **'No tienes reservas aún'**
  String get noReservations;

  /// No description provided for @noPayments.
  ///
  /// In es, this message translates to:
  /// **'No hay pagos registrados'**
  String get noPayments;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get changePhoto;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas cerrar sesión?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get noInternet;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido de vuelta!'**
  String get welcomeBack;

  /// No description provided for @exploreHosterias.
  ///
  /// In es, this message translates to:
  /// **'Explora las hosterías de Sigchos'**
  String get exploreHosterias;

  /// No description provided for @popularHosterias.
  ///
  /// In es, this message translates to:
  /// **'Hosterías destacadas'**
  String get popularHosterias;

  /// No description provided for @nearYou.
  ///
  /// In es, this message translates to:
  /// **'Cerca de ti'**
  String get nearYou;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get viewAll;

  /// No description provided for @viewOnMap.
  ///
  /// In es, this message translates to:
  /// **'Ver en mapa'**
  String get viewOnMap;

  /// No description provided for @selectDates.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fechas'**
  String get selectDates;

  /// No description provided for @reservationDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la reserva'**
  String get reservationDetails;

  /// No description provided for @paymentDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles del pago'**
  String get paymentDetails;

  /// No description provided for @bookingSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Reserva realizada con éxito!'**
  String get bookingSuccess;

  /// No description provided for @paymentSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Pago procesado con éxito!'**
  String get paymentSuccess;

  /// No description provided for @cancellationSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada exitosamente'**
  String get cancellationSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
