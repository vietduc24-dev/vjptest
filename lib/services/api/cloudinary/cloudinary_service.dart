import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  CloudinaryService._();
  static final instance = CloudinaryService._();

  String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  Future<String?> uploadImage(File imageFile) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print('❌ Cloudinary configuration missing');
      return null;
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'] as String;
      }
      return null;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }
}
