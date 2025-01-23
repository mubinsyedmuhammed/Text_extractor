import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
        canvasColor: Colors.grey[200],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

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
   ImagePainterController _controller = ImagePainterController();
  // final ImagePainterController _controller = ImagePainterController(
  //   fill: false,
  //   color: Colors.black,
  //   mode: PaintMode.rect,
  //   strokeWidth: 2.0,
  // );

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
          // log("File selected (Web): ${result.files.single.bytes!.length} bytes");
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

//   Future<void> _pickFile() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.image,
//   );

//   if (result != null) {
//     if (mounted) {
//       setState(() {
//         _imageBytes = result.files.single.bytes;
//         _controller.dispose();  // Dispose of the old controller safely
//         _controller = ImagePainterController(
//           fill: false,
//           color: Colors.black,
//           mode: PaintMode.rect,
//           strokeWidth: 2.0,
//         );
//       });
//       }
//     } else {
//     log("File selection canceled.");
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No image selected or invalid file')),
//       );
//     }
//   }
// }



  Future<void> _cropImage() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }
    
    final img.Image? decodedImage = img.decodeImage(_imageBytes!);

    if (decodedImage != null) {
      final img.Image croppedImage = img.copyCrop(decodedImage, 0, 0, 200, 200);
      final Uint8List croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));

      log("Cropped Image Size: ${croppedBytes.length} bytes");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cropped Image Size: ${croppedBytes.length} bytes')),
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
                  _buildTextField(_nameController, "Name"),
                  _buildTextField(_emailController, "Email"),
                  _buildTextField(_ageController, "Age", isNumeric: true),
                  _buildTextField(_genderController, "Gender"),
                  _buildTextField(_addressController, "Address"),
                  _buildTextField(_phoneController, "Phone Number", isNumeric: true),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _cropImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Crop Image"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
    );
  }
}
