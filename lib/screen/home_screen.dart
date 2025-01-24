import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:image/image.dart' as img; // Add image package for image manipulation

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.teal,
      ),
      body: const ROISelectionScreen(),
    );
  }
}

class ROISelectionScreen extends StatefulWidget {
  const ROISelectionScreen({super.key});

  @override
  ROISelectionScreenState createState() => ROISelectionScreenState();
}

class ROISelectionScreenState extends State<ROISelectionScreen> {
  Uint8List? _imageBytes;
  ImagePainterController _controller = ImagePainterController(
    fill: false,
    color: Colors.black,
    mode: PaintMode.rect,
    strokeWidth: 2.0,
  );

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      if (kIsWeb) {
        if (result.files.single.bytes != null) {
          setState(() {
            _imageBytes = result.files.single.bytes;
            _controller.clear();
            _controller = ImagePainterController(
              fill: false,
              color: Colors.black,
              mode: PaintMode.rect,
              strokeWidth: 2.0,
            );
          });
        }
      } else {
        if (result.files.single.path != null) {
          File file = File(result.files.single.path!);
          _imageBytes = await file.readAsBytes();
          setState(() {
            _controller.clear();
            _controller = ImagePainterController(
              fill: false,
              color: Colors.black,
              mode: PaintMode.rect,
              strokeWidth: 2.0,
            );
          });
        }
      }
    } else {
      log("File selection canceled.");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected or invalid file')),
      );
    }
  }

  Future<void> _extractTextFromCroppedImage(String field) async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    final img.Image? decodedImage = img.decodeImage(_imageBytes!);

    if (decodedImage != null) {
      // Get the selected ROI coordinates
      final rect = _controller.paintArea;

      if (rect != null) {
        img.copyCrop(
          decodedImage,
          x: rect.left.toInt(),
          y: rect.top.toInt(),
          width: rect.width.toInt(),
          height: rect.height.toInt(),
        );


        // Here, you would send the cropped image to your backend for text extraction
        // This is just a placeholder for the backend call
        // Example: String extractedText = await backendService.extractText(croppedBytes);

        // For now, we'll mock a response based on the field
        String extractedText = _mockTextExtraction(field);

        // Update the corresponding TextField with the extracted text
        switch (field) {
          case 'Name':
            _nameController.text = extractedText;
            break;
          case 'Email':
            _emailController.text = extractedText;
            break;
          case 'Age':
            _ageController.text = extractedText;
            break;
          case 'Gender':
            _genderController.text = extractedText;
            break;
          case 'Address':
            _addressController.text = extractedText;
            break;
          case 'Phone Number':
            _phoneController.text = extractedText;
            break;
        }

        log("Extracted Text: $extractedText");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extracted Text: $extractedText')),
        );
      }
    }
  }

  String _mockTextExtraction(String field) {
    // Mock extraction based on the field for now
    return 'Sample $field';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(_nameController, "Name", "Name"),
                  _buildTextField(_emailController, "Email", "Email"),
                  _buildTextField(_ageController, "Age", "Age", isNumeric: true),
                  _buildTextField(_genderController, "Gender", "Gender"),
                  _buildTextField(_addressController, "Address", "Address"),
                  _buildTextField(_phoneController, "Phone Number", "Phone Number", isNumeric: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Form Submitted!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Colors.grey),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _imageBytes == null
                  ? Center(
                      child: ElevatedButton(
                        onPressed: _pickFile,
                        child: const Text("Upload Image"),
                      ),
                    )
                  : Expanded(
                      child: Stack(
                        children: [
                          ImagePainter.memory(
                            _imageBytes!,
                            controller: _controller,
                            scalable: true,
                          ),
                          Positioned(
                            top: 50,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.black, size: 30),
                              onPressed: () {
                                setState(() {
                                  _imageBytes = null;
                                  _controller.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String field, {bool isNumeric = false}) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.teal),
          onPressed: () {
            _extractTextFromCroppedImage(field);
          },
        ),
      ],
    );
  }
}

extension on ImagePainterController {
   get paintArea => null;
}
