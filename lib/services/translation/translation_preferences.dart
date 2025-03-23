import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum TranslationLanguage {
  none,    // Không dịch
  english, // Tiếng Anh
  vietnamese, // Tiếng Việt
  japanese, // Tiếng Nhật
}

class TranslationPreferences {
  static const _storage = FlutterSecureStorage();
  static const _languageKey = 'translation_language';

  static Future<void> setLanguage(TranslationLanguage language) async {
    await _storage.write(key: _languageKey, value: language.toString());
  }

  static Future<TranslationLanguage> getLanguage() async {
    final value = await _storage.read(key: _languageKey);
    if (value == null) return TranslationLanguage.none;
    
    return TranslationLanguage.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => TranslationLanguage.none,
    );
  }

  static String getLanguageCode(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.english:
        return 'en';
      case TranslationLanguage.vietnamese:
        return 'vi';
      case TranslationLanguage.japanese:
        return 'ja';
      case TranslationLanguage.none:
        return '';
    }
  }

  static String getLanguageName(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.english:
        return 'Tiếng Anh';
      case TranslationLanguage.vietnamese:
        return 'Tiếng Việt';
      case TranslationLanguage.japanese:
        return 'Tiếng Nhật';
      case TranslationLanguage.none:
        return 'Không dịch';
    }
  }
} 