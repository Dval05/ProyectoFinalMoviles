import 'package:flutter/material.dart';

/// ViewModel para manejar el idioma de la aplicación (Internacionalización)
class LocaleViewModel extends ChangeNotifier {
  Locale _locale = const Locale('es'); // Español por defecto

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['es', 'en'].contains(locale.languageCode)) return;

    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    notifyListeners();
  }
}
