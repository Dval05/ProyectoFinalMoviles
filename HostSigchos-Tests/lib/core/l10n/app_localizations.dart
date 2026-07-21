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

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, ubicación...'**
  String get searchPlaceholder;

  /// No description provided for @chooseDates.
  ///
  /// In es, this message translates to:
  /// **'Elige tus fechas'**
  String get chooseDates;

  /// No description provided for @stop.
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get stop;

  /// No description provided for @followRoute.
  ///
  /// In es, this message translates to:
  /// **'Seguir Ruta'**
  String get followRoute;

  /// No description provided for @calculatingRoute.
  ///
  /// In es, this message translates to:
  /// **'Calculando ruta...'**
  String get calculatingRoute;

  /// No description provided for @routeRecalculated.
  ///
  /// In es, this message translates to:
  /// **'Ruta recalculada automáticamente'**
  String get routeRecalculated;

  /// No description provided for @noPlacesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron hosterías'**
  String get noPlacesFound;

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

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccount;

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

  /// No description provided for @inReview.
  ///
  /// In es, this message translates to:
  /// **'En Revisión'**
  String get inReview;

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

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get chooseFromGallery;

  /// No description provided for @errorGettingImage.
  ///
  /// In es, this message translates to:
  /// **'Error al obtener la imagen'**
  String get errorGettingImage;

  /// No description provided for @selectBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu fecha de nacimiento'**
  String get selectBirthDate;

  /// No description provided for @invalidDateFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de fecha inválido'**
  String get invalidDateFormat;

  /// No description provided for @mustBeAdult.
  ///
  /// In es, this message translates to:
  /// **'Debes ser mayor de 18 años'**
  String get mustBeAdult;

  /// No description provided for @idCard.
  ///
  /// In es, this message translates to:
  /// **'Cédula de Identidad'**
  String get idCard;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @tapToChoose.
  ///
  /// In es, this message translates to:
  /// **'Toca para elegir'**
  String get tapToChoose;

  /// No description provided for @countryCode.
  ///
  /// In es, this message translates to:
  /// **'Cód'**
  String get countryCode;

  /// No description provided for @countryOfOrigin.
  ///
  /// In es, this message translates to:
  /// **'País de origen'**
  String get countryOfOrigin;

  /// No description provided for @city.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get city;

  /// No description provided for @cityOrProvince.
  ///
  /// In es, this message translates to:
  /// **'Ciudad / Provincia'**
  String get cityOrProvince;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In es, this message translates to:
  /// **'O continúa con'**
  String get orContinueWith;

  /// No description provided for @profileIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil está incompleto. Completa tus datos para realizar reservas.'**
  String get profileIncomplete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @paymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get paymentMethod;

  /// No description provided for @creditDebitCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta Crédito/Débito'**
  String get creditDebitCard;

  /// No description provided for @bankTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia Bancaria'**
  String get bankTransfer;

  /// No description provided for @deuna.
  ///
  /// In es, this message translates to:
  /// **'Deuna'**
  String get deuna;

  /// No description provided for @cardDetails.
  ///
  /// In es, this message translates to:
  /// **'Datos de la Tarjeta'**
  String get cardDetails;

  /// No description provided for @bankDetails.
  ///
  /// In es, this message translates to:
  /// **'Datos Bancarios'**
  String get bankDetails;

  /// No description provided for @transferInstructions.
  ///
  /// In es, this message translates to:
  /// **'Realiza la transferencia a la siguiente cuenta y luego confirma tu pago.'**
  String get transferInstructions;

  /// No description provided for @bankName.
  ///
  /// In es, this message translates to:
  /// **'Banco: Pichincha'**
  String get bankName;

  /// No description provided for @accountType.
  ///
  /// In es, this message translates to:
  /// **'Tipo: Cuenta Corriente'**
  String get accountType;

  /// No description provided for @accountNumber.
  ///
  /// In es, this message translates to:
  /// **'Cuenta: 2100555555'**
  String get accountNumber;

  /// No description provided for @ownerName.
  ///
  /// In es, this message translates to:
  /// **'Titular: HostSigchos S.A.'**
  String get ownerName;

  /// No description provided for @idNumber.
  ///
  /// In es, this message translates to:
  /// **'RUC: 1790000000001'**
  String get idNumber;

  /// No description provided for @deunaInstructions.
  ///
  /// In es, this message translates to:
  /// **'Envía el pago por Deuna al siguiente número y luego confirma tu pago.'**
  String get deunaInstructions;

  /// No description provided for @deunaNumber.
  ///
  /// In es, this message translates to:
  /// **'Número: 0991234567'**
  String get deunaNumber;

  /// No description provided for @confirmPayment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Pago'**
  String get confirmPayment;

  /// No description provided for @uploadReceipt.
  ///
  /// In es, this message translates to:
  /// **'Subir comprobante'**
  String get uploadReceipt;

  /// No description provided for @receiptUploaded.
  ///
  /// In es, this message translates to:
  /// **'Comprobante subido'**
  String get receiptUploaded;

  /// No description provided for @transferNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de transferencia/transacción'**
  String get transferNumber;

  /// No description provided for @verification.
  ///
  /// In es, this message translates to:
  /// **'Verificación'**
  String get verification;

  /// No description provided for @verifyAccount.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu cuenta'**
  String get verifyAccount;

  /// No description provided for @verifyAccountDescription.
  ///
  /// In es, this message translates to:
  /// **'Para mayor seguridad, verifica tu correo electrónico y número de teléfono.'**
  String get verifyAccountDescription;

  /// No description provided for @emailVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación de Email'**
  String get emailVerification;

  /// No description provided for @phoneVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación de Teléfono'**
  String get phoneVerification;

  /// No description provided for @sendVerificationEmail.
  ///
  /// In es, this message translates to:
  /// **'Enviar correo de verificación'**
  String get sendVerificationEmail;

  /// No description provided for @alreadyVerifiedEmail.
  ///
  /// In es, this message translates to:
  /// **'Ya verifiqué mi email'**
  String get alreadyVerifiedEmail;

  /// No description provided for @resendEmail.
  ///
  /// In es, this message translates to:
  /// **'Reenviar correo'**
  String get resendEmail;

  /// No description provided for @sendSmsCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código SMS'**
  String get sendSmsCode;

  /// No description provided for @verifySmsCode.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get verifySmsCode;

  /// No description provided for @resendCode.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resendCode;

  /// No description provided for @verified.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get verified;

  /// No description provided for @skipForNow.
  ///
  /// In es, this message translates to:
  /// **'Omitir por ahora'**
  String get skipForNow;

  /// No description provided for @canVerifyLater.
  ///
  /// In es, this message translates to:
  /// **'Podrás verificar tu cuenta más tarde desde tu perfil.'**
  String get canVerifyLater;

  /// No description provided for @createPassword.
  ///
  /// In es, this message translates to:
  /// **'Crear contraseña'**
  String get createPassword;

  /// No description provided for @createPasswordDescription.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas crear una contraseña para también poder iniciar sesión con tu correo electrónico?'**
  String get createPasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @passwordLinked.
  ///
  /// In es, this message translates to:
  /// **'¡Contraseña vinculada exitosamente!'**
  String get passwordLinked;

  /// No description provided for @paymentInReview.
  ///
  /// In es, this message translates to:
  /// **'Pago en Revisión'**
  String get paymentInReview;

  /// No description provided for @paymentInReviewMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu pago ha sido registrado y se encuentra en revisión.'**
  String get paymentInReviewMessage;

  /// No description provided for @paymentInReviewWarning.
  ///
  /// In es, this message translates to:
  /// **'Si el pago no se confirma dentro de 48 horas, el estado cambiará a pendiente.'**
  String get paymentInReviewWarning;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @pendingPaymentReminder.
  ///
  /// In es, this message translates to:
  /// **'¡Falta realizar tu pago para confirmar tu reserva!'**
  String get pendingPaymentReminder;

  /// No description provided for @paymentReminderScheduled.
  ///
  /// In es, this message translates to:
  /// **'Te recordaremos realizar tu pago para confirmar la reserva.'**
  String get paymentReminderScheduled;

  /// No description provided for @hotelMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa de Hosterías'**
  String get hotelMap;

  /// No description provided for @getDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get getDirections;

  /// No description provided for @whatDates.
  ///
  /// In es, this message translates to:
  /// **'¿En qué fechas deseas hospedarte?'**
  String get whatDates;

  /// No description provided for @availableDatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Disponibles para tus fechas'**
  String get availableDatesTitle;

  /// No description provided for @helloUser.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String helloUser(String name);

  /// No description provided for @helpAndSupport.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y Soporte'**
  String get helpAndSupport;

  /// No description provided for @noPaymentHistory.
  ///
  /// In es, this message translates to:
  /// **'No tienes pagos registrados.'**
  String get noPaymentHistory;

  /// No description provided for @reference.
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get reference;

  /// No description provided for @method.
  ///
  /// In es, this message translates to:
  /// **'Método'**
  String get method;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @code.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get code;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @areYouSureCancel.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cancelar esta reserva? Esta acción no se puede deshacer.'**
  String get areYouSureCancel;

  /// No description provided for @yesCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get yesCancel;

  /// No description provided for @noKeep.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get noKeep;

  /// No description provided for @cancelSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada exitosamente'**
  String get cancelSuccess;

  /// No description provided for @cancelError.
  ///
  /// In es, this message translates to:
  /// **'Error al cancelar: '**
  String get cancelError;

  /// No description provided for @supportInfoText.
  ///
  /// In es, this message translates to:
  /// **'Para soporte técnico, contacta a:'**
  String get supportInfoText;

  /// No description provided for @advancedFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros Avanzados'**
  String get advancedFilters;

  /// No description provided for @priceRange.
  ///
  /// In es, this message translates to:
  /// **'Rango de Precios (\$)'**
  String get priceRange;

  /// No description provided for @locationFilterHint.
  ///
  /// In es, this message translates to:
  /// **'Ubicación (Ej: Latacunga)'**
  String get locationFilterHint;

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @sortTitle.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortTitle;

  /// No description provided for @sortNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get sortNone;

  /// No description provided for @sortPriceAsc.
  ///
  /// In es, this message translates to:
  /// **'Precio: Menor a Mayor'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In es, this message translates to:
  /// **'Precio: Mayor a Menor'**
  String get sortPriceDesc;

  /// No description provided for @sortNameAsc.
  ///
  /// In es, this message translates to:
  /// **'Nombre: A - Z'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In es, this message translates to:
  /// **'Nombre: Z - A'**
  String get sortNameDesc;

  /// No description provided for @sortRatingDesc.
  ///
  /// In es, this message translates to:
  /// **'Mejor valorados'**
  String get sortRatingDesc;

  /// No description provided for @sortRatingAsc.
  ///
  /// In es, this message translates to:
  /// **'Peor valorados'**
  String get sortRatingAsc;

  /// No description provided for @discoverSigchos.
  ///
  /// In es, this message translates to:
  /// **'Descubre Sigchos'**
  String get discoverSigchos;

  /// No description provided for @topRated.
  ///
  /// In es, this message translates to:
  /// **'Top Valorados'**
  String get topRated;

  /// No description provided for @noPlacesAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay lugares disponibles para estas fechas.'**
  String get noPlacesAvailable;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @popularServices.
  ///
  /// In es, this message translates to:
  /// **'Servicios Populares'**
  String get popularServices;

  /// No description provided for @servicesNotSpecified.
  ///
  /// In es, this message translates to:
  /// **'Servicios no especificados'**
  String get servicesNotSpecified;

  /// No description provided for @reviews.
  ///
  /// In es, this message translates to:
  /// **'Opiniones'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get writeReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In es, this message translates to:
  /// **'No hay opiniones todavía.'**
  String get noReviewsYet;

  /// No description provided for @beTheFirstToReview.
  ///
  /// In es, this message translates to:
  /// **'¡Sé el primero en calificar este lugar!'**
  String get beTheFirstToReview;

  /// No description provided for @welcomeTo.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a HostSigchos'**
  String get welcomeTo;

  /// No description provided for @signInToContinue.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get signInToContinue;

  /// No description provided for @emailOrPlaceName.
  ///
  /// In es, this message translates to:
  /// **'Correo / Nombre de local'**
  String get emailOrPlaceName;

  /// No description provided for @registerHere.
  ///
  /// In es, this message translates to:
  /// **'Regístrate aquí'**
  String get registerHere;

  /// No description provided for @biometricLogin.
  ///
  /// In es, this message translates to:
  /// **'Huella/Face ID'**
  String get biometricLogin;

  /// No description provided for @biometricSetupMessage.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con correo y contraseña primero para habilitar esta opción.'**
  String get biometricSetupMessage;

  /// No description provided for @keepSession.
  ///
  /// In es, this message translates to:
  /// **'Mantener sesión iniciada'**
  String get keepSession;

  /// No description provided for @emailNotVerified.
  ///
  /// In es, this message translates to:
  /// **'Por favor verifica tu correo electrónico antes de iniciar sesión.'**
  String get emailNotVerified;

  /// No description provided for @idTypeCedula.
  ///
  /// In es, this message translates to:
  /// **'Cédula'**
  String get idTypeCedula;

  /// No description provided for @idTypePassport.
  ///
  /// In es, this message translates to:
  /// **'Pasaporte'**
  String get idTypePassport;

  /// No description provided for @pleaseWait.
  ///
  /// In es, this message translates to:
  /// **'Por favor espera...'**
  String get pleaseWait;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío'**
  String get yourCartIsEmpty;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @noRoomsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay habitaciones disponibles'**
  String get noRoomsAvailable;

  /// No description provided for @pleaseSelectDates.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona las fechas de estadía'**
  String get pleaseSelectDates;

  /// No description provided for @pleaseEnterOtherPersonName.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa el nombre de la otra persona'**
  String get pleaseEnterOtherPersonName;

  /// No description provided for @addedToCart.
  ///
  /// In es, this message translates to:
  /// **'Añadido a tu reserva (Carrito)'**
  String get addedToCart;

  /// No description provided for @addRoom.
  ///
  /// In es, this message translates to:
  /// **'Añadir Habitación'**
  String get addRoom;

  /// No description provided for @roomDataNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Error: Datos de habitación no disponibles'**
  String get roomDataNotAvailable;

  /// No description provided for @roomDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la Habitación'**
  String get roomDetails;

  /// No description provided for @bookForOtherPerson.
  ///
  /// In es, this message translates to:
  /// **'Reservar para otra persona'**
  String get bookForOtherPerson;

  /// No description provided for @activateIfYouWontStay.
  ///
  /// In es, this message translates to:
  /// **'Activa esto si no te hospedarás tú'**
  String get activateIfYouWontStay;

  /// No description provided for @totalToPay.
  ///
  /// In es, this message translates to:
  /// **'Total a pagar:'**
  String get totalToPay;

  /// No description provided for @bookingConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Reserva Confirmada'**
  String get bookingConfirmed;

  /// No description provided for @proceedToPayment.
  ///
  /// In es, this message translates to:
  /// **'Proceder al Pago'**
  String get proceedToPayment;

  /// No description provided for @payLater.
  ///
  /// In es, this message translates to:
  /// **'Pagar más tarde'**
  String get payLater;

  /// No description provided for @mustSignInToBook.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para reservar'**
  String get mustSignInToBook;

  /// No description provided for @bookingCheckout.
  ///
  /// In es, this message translates to:
  /// **'Checkout Reserva'**
  String get bookingCheckout;

  /// No description provided for @cartIsEmpty.
  ///
  /// In es, this message translates to:
  /// **'El carrito está vacío'**
  String get cartIsEmpty;

  /// No description provided for @clientBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas de Clientes'**
  String get clientBookings;

  /// No description provided for @noHostelsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tienes hosterías registradas.'**
  String get noHostelsRegistered;

  /// No description provided for @hostelSavedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Hostería guardada exitosamente'**
  String get hostelSavedSuccessfully;

  /// No description provided for @noBookingsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay reservas registradas.'**
  String get noBookingsRegistered;

  /// No description provided for @bookingId.
  ///
  /// In es, this message translates to:
  /// **'ID Reserva'**
  String get bookingId;

  /// No description provided for @userId.
  ///
  /// In es, this message translates to:
  /// **'Usuario ID'**
  String get userId;

  /// No description provided for @dates.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get dates;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @action.
  ///
  /// In es, this message translates to:
  /// **'Acción'**
  String get action;

  /// No description provided for @manage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get manage;

  /// No description provided for @manageBooking.
  ///
  /// In es, this message translates to:
  /// **'Gestionar Reserva'**
  String get manageBooking;

  /// No description provided for @changeStatus.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado:'**
  String get changeStatus;

  /// No description provided for @statusUpdatedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Estado actualizado exitosamente'**
  String get statusUpdatedSuccessfully;

  /// No description provided for @newPromotion.
  ///
  /// In es, this message translates to:
  /// **'Nueva Promoción'**
  String get newPromotion;

  /// No description provided for @noPromotionsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay promociones registradas.'**
  String get noPromotionsRegistered;

  /// No description provided for @guestsBedsToBook.
  ///
  /// In es, this message translates to:
  /// **'Huéspedes (Camas a reservar)'**
  String get guestsBedsToBook;

  /// No description provided for @max.
  ///
  /// In es, this message translates to:
  /// **'Máx.'**
  String get max;

  /// No description provided for @otherPersonName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la otra persona'**
  String get otherPersonName;

  /// No description provided for @specialRequests.
  ///
  /// In es, this message translates to:
  /// **'Peticiones especiales (opcional)'**
  String get specialRequests;

  /// No description provided for @payInNextStep.
  ///
  /// In es, this message translates to:
  /// **'Podrás realizar el pago en el siguiente paso'**
  String get payInNextStep;

  /// No description provided for @addToMyBooking.
  ///
  /// In es, this message translates to:
  /// **'Añadir a mi Reserva'**
  String get addToMyBooking;

  /// No description provided for @notEnoughRooms.
  ///
  /// In es, this message translates to:
  /// **'No hay suficientes habitaciones disponibles para esas fechas.'**
  String get notEnoughRooms;

  /// No description provided for @overlappingBooking.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una reserva activa en estas fechas. Activa la opción \'Reservar para otra persona\' si la reserva no es para ti.'**
  String get overlappingBooking;

  /// No description provided for @perBedPerNight.
  ///
  /// In es, this message translates to:
  /// **'cama / noche'**
  String get perBedPerNight;

  /// No description provided for @bookingCreatedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'¡Reserva Creada Exitosamente!'**
  String get bookingCreatedSuccessfully;

  /// No description provided for @bookingRequestRegistered.
  ///
  /// In es, this message translates to:
  /// **'Hemos registrado tu solicitud de reserva en la hostería.'**
  String get bookingRequestRegistered;

  /// No description provided for @bookingCodes.
  ///
  /// In es, this message translates to:
  /// **'Códigos de Reserva:'**
  String get bookingCodes;

  /// No description provided for @paymentReminder.
  ///
  /// In es, this message translates to:
  /// **'Te recordaremos realizar tu pago para confirmar la reserva.'**
  String get paymentReminder;

  /// No description provided for @errorProcessingBooking.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar reserva de {tipo}: {error}'**
  String errorProcessingBooking(String tipo, String error);

  /// No description provided for @bookingFor.
  ///
  /// In es, this message translates to:
  /// **'Para: {name}'**
  String bookingFor(String name);

  /// No description provided for @promotionsApplied.
  ///
  /// In es, this message translates to:
  /// **'Promociones aplicadas al carrito'**
  String get promotionsApplied;

  /// No description provided for @confirmAllBookings.
  ///
  /// In es, this message translates to:
  /// **'Confirmar todas las reservas'**
  String get confirmAllBookings;

  /// No description provided for @signInToReview.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para calificar'**
  String get signInToReview;

  /// No description provided for @howWasThePlace.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tal te pareció el lugar?'**
  String get howWasThePlace;

  /// No description provided for @yourOpinionHelps.
  ///
  /// In es, this message translates to:
  /// **'Tu opinión ayuda a otros viajeros a elegir mejor.'**
  String get yourOpinionHelps;

  /// No description provided for @writeYourRecommendation.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu recomendación o comentario...'**
  String get writeYourRecommendation;

  /// No description provided for @pleaseWriteAComment.
  ///
  /// In es, this message translates to:
  /// **'Por favor escribe un comentario'**
  String get pleaseWriteAComment;

  /// No description provided for @thanksForYourOpinion.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu opinión!'**
  String get thanksForYourOpinion;

  /// No description provided for @errorSendingReview.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar la reseña'**
  String get errorSendingReview;

  /// No description provided for @publishReview.
  ///
  /// In es, this message translates to:
  /// **'Publicar Opinión'**
  String get publishReview;

  /// No description provided for @couldNotLoadInformation.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la información'**
  String get couldNotLoadInformation;

  /// No description provided for @seeAvailableRooms.
  ///
  /// In es, this message translates to:
  /// **'Ver Habitaciones Disponibles'**
  String get seeAvailableRooms;

  /// No description provided for @customerBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas de Clientes'**
  String get customerBookings;

  /// No description provided for @logOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logOut;

  /// No description provided for @welcomeAdmin.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido, {name}!'**
  String welcomeAdmin(String name);

  /// No description provided for @adminSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de tu plataforma web de administración B2B.'**
  String get adminSummary;

  /// No description provided for @activeHostels.
  ///
  /// In es, this message translates to:
  /// **'Hosterías Activas'**
  String get activeHostels;

  /// No description provided for @activeBookings.
  ///
  /// In es, this message translates to:
  /// **'Reservas Activas'**
  String get activeBookings;

  /// No description provided for @totalIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Totales'**
  String get totalIncome;

  /// No description provided for @rooms.
  ///
  /// In es, this message translates to:
  /// **'Habitaciones'**
  String get rooms;

  /// No description provided for @selectDates.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fechas'**
  String get selectDates;

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myHostels.
  ///
  /// In es, this message translates to:
  /// **'Mis Hosterías'**
  String get myHostels;

  /// No description provided for @promotions.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get promotions;

  /// No description provided for @addHostel.
  ///
  /// In es, this message translates to:
  /// **'Añadir Hostería'**
  String get addHostel;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @totalPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio Total'**
  String get totalPrice;

  /// No description provided for @guests.
  ///
  /// In es, this message translates to:
  /// **'Huéspedes'**
  String get guests;

  /// No description provided for @night.
  ///
  /// In es, this message translates to:
  /// **'noche'**
  String get night;

  /// No description provided for @nights.
  ///
  /// In es, this message translates to:
  /// **'noche(s)'**
  String get nights;

  /// No description provided for @incompleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil'**
  String get incompleteProfileTitle;

  /// No description provided for @incompleteProfileDesc.
  ///
  /// In es, this message translates to:
  /// **'Hemos notado que tu perfil está incompleto. Te recomendamos llenar tus datos personales (como cédula y teléfono) ya que serán necesarios para realizar reservas.'**
  String get incompleteProfileDesc;

  /// No description provided for @completeNow.
  ///
  /// In es, this message translates to:
  /// **'Completar ahora'**
  String get completeNow;

  /// No description provided for @later.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get later;

  /// No description provided for @verifyEmailToContinue.
  ///
  /// In es, this message translates to:
  /// **'Por favor, verifica tu correo antes de continuar.'**
  String get verifyEmailToContinue;

  /// No description provided for @landingTitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre HostSigchos'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentra el lugar perfecto para tu próxima aventura en la naturaleza.'**
  String get landingSubtitle;

  /// No description provided for @supportInfo.
  ///
  /// In es, this message translates to:
  /// **'Para soporte técnico, contacta a:'**
  String get supportInfo;

  /// No description provided for @chatbotWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy tu asistente virtual. ¿Prefieres comunicarte solo por texto o también con audio? Puedes activar el volumen arriba. ¿En qué te ayudo hoy?'**
  String get chatbotWelcome;

  /// No description provided for @virtualAssistant.
  ///
  /// In es, this message translates to:
  /// **'Asistente Virtual'**
  String get virtualAssistant;

  /// No description provided for @loginSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión exitoso'**
  String get loginSuccessTitle;

  /// No description provided for @loginSuccessBody.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido de vuelta, {name}!'**
  String loginSuccessBody(String name);

  /// No description provided for @bookingCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva cancelada'**
  String get bookingCancelledTitle;

  /// No description provided for @bookingCancelledBody.
  ///
  /// In es, this message translates to:
  /// **'Tu reserva ha sido cancelada exitosamente.'**
  String get bookingCancelledBody;

  /// No description provided for @bookingBlockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Reserva bloqueada'**
  String get bookingBlockedTitle;

  /// No description provided for @bookingBlockedBody.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la reserva para {roomType}. {error}'**
  String bookingBlockedBody(String roomType, String error);

  /// No description provided for @voiceMessage.
  ///
  /// In es, this message translates to:
  /// **'🎵 Mensaje de voz'**
  String get voiceMessage;

  /// No description provided for @viewSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Ver Sugerencia'**
  String get viewSuggestion;

  /// No description provided for @suggestionsForYou.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias para ti'**
  String get suggestionsForYou;

  /// No description provided for @noSuggestionsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay sugerencias disponibles.'**
  String get noSuggestionsAvailable;

  /// No description provided for @typeMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje...'**
  String get typeMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @markAsRead.
  ///
  /// In es, this message translates to:
  /// **'Leídas'**
  String get markAsRead;

  /// No description provided for @deleteAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get deleteAll;

  /// No description provided for @suggestedRooms.
  ///
  /// In es, this message translates to:
  /// **'Habitaciones sugeridas'**
  String get suggestedRooms;

  /// No description provided for @unknownHotel.
  ///
  /// In es, this message translates to:
  /// **'Hotel Desconocido'**
  String get unknownHotel;

  /// No description provided for @addressNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Dirección no disponible'**
  String get addressNotAvailable;

  /// No description provided for @roomFallback.
  ///
  /// In es, this message translates to:
  /// **'Habitación'**
  String get roomFallback;

  /// No description provided for @noHosteriasFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron hosterías.'**
  String get noHosteriasFound;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, ubicación...'**
  String get searchHint;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Políticas de Privacidad'**
  String get privacyPolicy;
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
