
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'yug5adda8';
  static const String uploadPreset = 'yug_adda_uploads';

  static Future<String> uploadMedia(XFile file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'yug_adda';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await file.readAsBytes(),
        filename: file.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['secure_url'] != null) {
      return data['secure_url'] as String;
    }

    throw Exception(
      data['error']?['message'] ?? 'Cloudinary upload failed',
    );
  }
}
