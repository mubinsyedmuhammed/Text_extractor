import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:text_extractor/services/roi_form.dart';
import 'package:text_extractor/widgets/image_viewer.dart';
import '../services/ocr_service.dart';


class ROISelectionView extends StatefulWidget {
  const ROISelectionView({super.key});

  @override
  ROISelectionViewState createState() => ROISelectionViewState();
}

class ROISelectionViewState extends State<ROISelectionView> {
  Uint8List? _imageBytes;
  late ImagePainterController _controller;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fieldControllers = {
    "Name": TextEditingController(),
    "Email": TextEditingController(),
    "Age": TextEditingController(),
    "Gender": TextEditingController(),
    "Address": TextEditingController(),
    "Phone Number": TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = ImagePainterController(
      fill: false,
      color: Colors.black,
      mode: PaintMode.rect,
      strokeWidth: 2.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _initializeController(); // Reinitialize the controller with the new image
      });
    } else {
      log("File selection canceled.");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected or invalid file')),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _controller.clear();
    });
  }

  Future<void> _extractTextFromCroppedImage(String field) async {
    if (_imageBytes == null) {
      _showSnackBar('Please upload an image');
      return;
    }

    final img.Image? decodedImage = img.decodeImage(_imageBytes!);
    if (decodedImage == null || _controller.paintHistory.isEmpty) {
      _showSnackBar('Invalid image or no ROI selected');
      return;
    }

    final paintInfo = _controller.paintHistory.last;
    if (paintInfo.mode != PaintMode.rect || paintInfo.offsets.length < 2) {
      _showSnackBar('Please draw a valid rectangular ROI.');
      return;
    }

    final int left = paintInfo.offsets[0]!.dx.toInt();
    final int top = paintInfo.offsets[0]!.dy.toInt();
    final int right = paintInfo.offsets[1]!.dx.toInt();
    final int bottom = paintInfo.offsets[1]!.dy.toInt();

    if (left >= right || top >= bottom) {
      _showSnackBar('Invalid region dimensions. Please select properly.');
      return;
    }

    try {
      final croppedImage = img.copyCrop(decodedImage, x: left, y: top, width: right - left, height: bottom - top);
      Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

      OCRService ocrService = OCRService();
      String extractedText = await ocrService.extractText(croppedBytes);

      if (extractedText.isEmpty) {
        _showSnackBar('No text found in the cropped region');
        return;
      }

      setState(() {
        _fieldControllers[field]?.text = extractedText;
      });

      _showSnackBar(extractedText);
    } catch (e) {
      log("Error during cropping/extraction: $e");
      _showSnackBar('Failed to process the image. Try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Form submitted successfully!');
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
            child: ROIForm(
              formKey: _formKey,
              fieldControllers: _fieldControllers,
              onExtract: _extractTextFromCroppedImage,
              onSubmit: _submitForm,
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Colors.grey),
        Expanded(
          flex: 2,
          child: ROIImageViewer(
            imageBytes: _imageBytes,
            controller: _controller,
            onPickFile: _pickFile,
            onClearImage: _clearImage,
          ),
        ),
      ],
    );
  }
}

