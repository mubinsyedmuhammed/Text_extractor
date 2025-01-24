import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;

class ImageService {
  Future<Uint8List?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return null;
    return kIsWeb ? result.files.single.bytes : File(result.files.single.path!).readAsBytes();
  }

  Uint8List cropImage(Uint8List imageBytes, int x, int y, int width, int height) {
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception("Invalid image data");
    final img.Image croppedImage = img.copyCrop(decodedImage,x: x,y: y,width: width,height: height);
    return Uint8List.fromList(img.encodePng(croppedImage)); // Return bytes
  }
}