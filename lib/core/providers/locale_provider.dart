import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeOverrideKey = 'app_locale_override';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString(_localeOverrideKey);
    if (override != null && override.isNotEmpty) {
      state = Locale(override);
      return;
    }
    // Auto-detect from system locale
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (systemLocale.languageCode == 'ar') {
      state = const Locale('ar');
    } else if (systemLocale.languageCode == 'fr') {
      state = const Locale('fr');
    } else {
      state = const Locale('en');
    }
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeOverrideKey, languageCode);
    state = Locale(languageCode);
  }
}
