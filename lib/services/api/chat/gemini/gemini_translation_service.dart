import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GeminiTranslationService {
    static final String apiKey = dotenv.env['API_KEY_GEMINI'] ?? '';
    static final String apiUrl = dotenv.env['API_URL_GEMINI'] ?? '';


  // Xác định ngôn ngữ của tin nhắn
  static Future<String> detectLanguage(String text) async {
    print("🔍 [Gemini] Nhận diện ngôn ngữ cho: $text");
    print("🔑 [Gemini] API Key: ${apiKey.substring(0, 10)}...");
    print("🌐 [Gemini] API URL: $apiUrl");

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Bạn là một trợ lý dịch thuật chuyên nghiệp. Hãy xác định ngôn ngữ của văn bản sau và trả về mã ISO-639-1 (ví dụ: 'vi' cho tiếng Việt, 'en' cho tiếng Anh, 'ja' cho tiếng Nhật):\n$text"
                }
              ]
            }
          ]
        }),
      );

      print("📝 [Gemini] Phản hồi API: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String detectedLang = data['candidates'][0]['content']['parts'][0]['text'].trim();
        print("✅ [Gemini] Ngôn ngữ xác định: $detectedLang");
        return detectedLang;
      } else {
        print("❌ [Gemini] Lỗi API (${response.statusCode}): ${response.body}");
        throw Exception('Lỗi xác định ngôn ngữ: ${response.body}');
      }
    } catch (e) {
      print("❌ [Gemini] Lỗi gọi API: $e");
      rethrow;
    }
  }
  // Dịch tin nhắn sang ngôn ngữ đích
 // Dịch tin nhắn sang ngôn ngữ đích
static Future<String> translate(String text, String targetLang) async {
  print("🔍 [Gemini] Dịch: '$text' -> $targetLang");
  print("🔑 [Gemini] API Key: ${apiKey.substring(0, 10)}...");
  print("🌐 [Gemini] API URL: $apiUrl");

  final prompt = """
Bạn là một trợ lý dịch thuật chuyên nghiệp. Hãy dịch đoạn văn sau sang ngôn ngữ đích: $targetLang.
Yêu cầu: ngắn gọn, tự nhiên, đúng ngữ cảnh giao tiếp đời thường, tránh văn phong máy móc.
Văn bản: $text
""";

  try {
    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    print("📝 [Gemini] Phản hồi API: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String translatedText = data['candidates'][0]['content']['parts'][0]['text'].trim();
      print("✅ [Gemini] Kết quả dịch: $translatedText");
      return translatedText;
    } else {
      print("❌ [Gemini] Lỗi API (${response.statusCode}): ${response.body}");
      throw Exception('Lỗi dịch: ${response.body}');
    }
  } catch (e) {
    print("❌ [Gemini] Lỗi gọi API: $e");
    rethrow;
  }
}
}