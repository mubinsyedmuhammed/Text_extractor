// services/ocr_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OCRService {
  final String apiUrl = "http://localhost:8000/extract_text/";

  Future<String> extractText(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData)['extracted_text'] ?? '';
      } else {
        return 'Failed to extract text';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
