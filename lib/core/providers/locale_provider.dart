import 'package:flutter/material.dart';

enum AppLanguage { english, vietnamese }

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi', 'VN'); // Default to Vietnamese

  Locale get locale => _locale;

  AppLanguage get currentLanguage => _locale.languageCode == 'vi'
      ? AppLanguage.vietnamese
      : AppLanguage.english;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        setLocale(const Locale('en', 'US'));
        break;
      case AppLanguage.vietnamese:
        setLocale(const Locale('vi', 'VN'));
        break;
    }
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'vi') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('vi', 'VN'));
    }
  }
}
