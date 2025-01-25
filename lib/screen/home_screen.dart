import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:text_extractor/services/ocr_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR and ROI Selection"),
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
  late final ImagePainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(
      fill: false,
      color: Colors.black,
      mode: PaintMode.rect,
      strokeWidth: 2.0,
    );
  }

  @override
  void dispose() {
    _controller.clear();  // Dispose of the controller when the widget is disposed
    super.dispose();
  }

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

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _controller.clear();
      });
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

    if (decodedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid image format')),
      );
      return;
    }

    if (_controller.paintHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ROI selected. Please draw a region to crop.')),
      );
      return;
    }

    final paintInfo = _controller.paintHistory.last;

    if (paintInfo.mode != PaintMode.rect || paintInfo.offsets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a valid rectangular ROI.')),
      );
      return;
    }

    final int left = paintInfo.offsets[0]!.dx.toInt();
    final int top = paintInfo.offsets[0]!.dy.toInt();
    final int right = paintInfo.offsets[1]!.dx.toInt();
    final int bottom = paintInfo.offsets[1]!.dy.toInt();

    if (left >= right || top >= bottom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid region dimensions. Please select properly.')),
      );
      return;
    }

    try {
      final croppedImage = img.copyCrop(
        decodedImage,
        x: left,
        y: top,
        width: right - left,
        height: bottom - top,
      );

      Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

      OCRService ocrService = OCRService();
      String extractedText = await ocrService.extractText(croppedBytes);

      if (extractedText.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text found in the cropped region')),
        );
        return;
      }

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
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid field selection')),
          );
          return;
      }

      log("Extracted Text: $extractedText");

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Extracted Text: $extractedText')),
      );
    } catch (e) {
      log("Error during cropping/extraction: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process the image. Try again.')),
      );
    }
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
