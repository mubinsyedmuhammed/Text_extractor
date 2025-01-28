import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// ignore: use_key_in_widget_constructors
class ImageUploader extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected or invalid file')),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Uploaded Document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _selectedImageBytes == null
          ? Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Upload Image"),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Image.memory(_selectedImageBytes!),
                ),
                Positioned(
                  top: 25,
                  right: 3,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red
                    ),
                    child: IconButton(
                      onPressed: _clearImage,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ),
              ],
            ),
    );
  }
}
