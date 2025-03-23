import '../api/chat/gemini/gemini_translation_service.dart';
import 'translation_preferences.dart';

class MessageTranslationService {
  static Future<String?> translateMessageIfNeeded(String message) async {
    try {
      print('🔄 [Translation] Bắt đầu xử lý tin nhắn: "$message"');
      
      // Lấy ngôn ngữ đã chọn từ preferences
      final targetLanguage = await TranslationPreferences.getLanguage();
      print('📱 [Translation] Ngôn ngữ đã chọn: ${TranslationPreferences.getLanguageName(targetLanguage)}');
      
      if (targetLanguage == TranslationLanguage.none) {
        print('⏭️ [Translation] Đã chọn không dịch, bỏ qua');
        return null;
      }

      // Xác định ngôn ngữ của tin nhắn
      print('🔍 [Translation] Đang xác định ngôn ngữ của tin nhắn...');
      final sourceLanguageCode = await GeminiTranslationService.detectLanguage(message);
      final targetLanguageCode = TranslationPreferences.getLanguageCode(targetLanguage);
      print('📋 [Translation] Ngôn ngữ nguồn: $sourceLanguageCode, Ngôn ngữ đích: $targetLanguageCode');

      // Nếu tin nhắn đã ở ngôn ngữ đích, không cần dịch
      if (sourceLanguageCode.trim().toLowerCase() == targetLanguageCode.toLowerCase()) {
        print('⏭️ [Translation] Tin nhắn đã ở ngôn ngữ đích, không cần dịch');
        return null;
      }

      // Dịch tin nhắn sử dụng Gemini API
      print('🔄 [Translation] Đang dịch tin nhắn...');
      final translatedText = await GeminiTranslationService.translate(
        message,
        TranslationPreferences.getLanguageName(targetLanguage),
      );
      print('✅ [Translation] Dịch thành công: "$translatedText"');

      return translatedText;
    } catch (e) {
      print('❌ [Translation] Lỗi trong quá trình dịch: $e');
      return null;
    }
  }
} 