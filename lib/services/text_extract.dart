import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TextExtractionService {
  // static const String _baseUrl = 'http://127.0.0.1:8000/extract_text/';
  static const String _baseUrl = 'http://127.0.0.1:8000/extract_text/';

  
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> responseBody = json.decode(response.body);
          String extractedText = responseBody['extracted_text'] ?? '';
          log('Extracted text: $extractedText');
          return extractedText;
        case 400:
          log('Bad request: ${response.body}');
          return '';
        case 500:
          log('Server error: ${response.body}');
          return '';
        default:
          log('Unexpected status code: ${response.statusCode}');
          return '';
      }
    } catch (e) {
      log('Network or parsing error: $e');
      return '';
    }
  }
}