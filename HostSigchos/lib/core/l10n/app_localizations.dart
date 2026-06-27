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
  /// **'Para soporte técnico, contacta a:\n\nEmail: soporte@hostsigchos.com\nTeléfono: +593 99 123 4567'**
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
