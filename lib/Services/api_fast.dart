import 'dart:typed_data';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiUrl = "http://127.0.0.1:8000/extract_text/";

  // Send image to FastAPI backend to extract text
  Future<String?> extractTextFromImage(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var extractedText = jsonDecode(responseData.body)['extracted_text'];
        return extractedText;
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      log("Error sending request: $e");
      return null;
    }
  }
}
