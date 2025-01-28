import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:text_extractor/services/ocr_service.dart';
import 'package:text_extractor/services/roi_form.dart';
import 'package:text_extractor/widgets/image_viewer.dart';

class ROISelection {
  late ImagePainterController controller;

  ROISelection({required this.controller});

  // Method to validate and return the selected ROI
  Rect? getROI() {
    if (controller.paintHistory.isEmpty) return null;

    final paintInfo = controller.paintHistory.last;
    if (paintInfo.mode != PaintMode.rect || paintInfo.offsets.length < 2) return null;

    final left = paintInfo.offsets[0]!.dx.toInt();
    final top = paintInfo.offsets[0]!.dy.toInt();
    final right = paintInfo.offsets[1]!.dx.toInt();
    final bottom = paintInfo.offsets[1]!.dy.toInt();

    if (left >= right || top >= bottom) return null;

    return Rect.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  // Method to crop the image based on the ROI
  img.Image? cropImage(Uint8List imageBytes) {
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    final roi = getROI();
    if (roi == null) return null;

    return img.copyCrop(decodedImage, x: roi.left.toInt(), y: roi.top.toInt(), width: roi.width.toInt(), height: roi.height.toInt());
  }
}


class ROISelectionView extends StatefulWidget {
  const ROISelectionView({super.key});

  @override
  State<ROISelectionView> createState() => ROISelectionViewState();
}

class ROISelectionViewState extends State<ROISelectionView> {
  Uint8List? _imageBytes;
  late ROISelection _roiSelection;
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
    _roiSelection = ROISelection(controller: _controller);
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
        _initializeController();
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

    final croppedImage = _roiSelection.cropImage(_imageBytes!);
    if (croppedImage == null) {
      _showSnackBar('Invalid image or no ROI selected');
      return;
    }

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
            onPickFile: _pickFile,
            onClearImage: _clearImage, 
            controller: _controller,
          ),
        ),
      ],
    );
  }
}
