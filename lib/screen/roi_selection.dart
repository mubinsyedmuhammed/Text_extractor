// screens/roi_selection_screen.dart
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:text_extractor/services/text_extract.dart';


class ROISelectionScreen extends StatefulWidget {
  const ROISelectionScreen({super.key});

  @override
  ROISelectionScreenState createState() => ROISelectionScreenState();
}

class ROISelectionScreenState extends State<ROISelectionScreen> {
  Uint8List? _imageBytes;
  final ImagePainterController _controller = ImagePainterController(
    fill: false,
    color: Colors.black,
    mode: PaintMode.rect,
    strokeWidth: 2.0,
  );

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


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFieldWithExtraction(
                label: "Name",
                field: "Name",
                onExtract: (text) {
                  // Handle extraction
                },
              ),
              // Other fields...
            ],
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
}
