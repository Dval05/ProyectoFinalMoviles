import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID')
  static final String googleWebClientId = _Env.googleWebClientId;

  @EnviedField(varName: 'GROQ_API_KEY')
  static final String groqApiKey = _Env.groqApiKey;

  @EnviedField(varName: 'FIREBASE_API_KEY_WEB')
  static final String firebaseApiKeyWeb = _Env.firebaseApiKeyWeb;

  @EnviedField(varName: 'FIREBASE_API_KEY_ANDROID')
  static final String firebaseApiKeyAndroid = _Env.firebaseApiKeyAndroid;

  @EnviedField(varName: 'FIREBASE_API_KEY_IOS')
  static final String firebaseApiKeyIos = _Env.firebaseApiKeyIos;


  @EnviedField(varName: 'SUPPORT_EMAIL', defaultValue: 'andrade.dval@gmail.com')
  static final String supportEmail = _Env.supportEmail;

  @EnviedField(varName: 'SUPPORT_PHONE', defaultValue: '593939185134')
  static final String supportPhone = _Env.supportPhone;
}
