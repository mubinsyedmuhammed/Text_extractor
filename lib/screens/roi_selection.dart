import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ROISelector extends StatefulWidget {
  final img.Image image;

  const ROISelector({super.key, required this.image});

  @override
  // ignore: library_private_types_in_public_api
  _ROISelectorState createState() => _ROISelectorState();
}

class _ROISelectorState extends State<ROISelector> {
  bool _isSelectingROI = false;
  Rect _roiRect = Rect.zero;
  img.Image? _croppedImage;

  void _toggleROISelection() {
    setState(() {
      _isSelectingROI = !_isSelectingROI;
      if (!_isSelectingROI) {
        // Crop the image if ROI is selected
        if (_roiRect != Rect.zero) {
          _croppedImage = img.copyCrop(
            widget.image,
            x: _roiRect.left.toInt(),
            y: _roiRect.top.toInt(),
            width: _roiRect.width.toInt(),
            height: _roiRect.height.toInt(),
          );
        }
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (_isSelectingROI) {
        _roiRect = Rect.fromPoints(
          _roiRect.topLeft,
          details.localPosition,
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_isSelectingROI) {
        // Finalize the ROI selection
        _roiRect = Rect.fromPoints(
          _roiRect.topLeft,
          details.localPosition,
        );
        _toggleROISelection();  // End ROI selection
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select ROI and Crop Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onPanUpdate: _isSelectingROI ? _onPanUpdate : null,
              onPanEnd: _isSelectingROI ? _onPanEnd : null,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                    image: MemoryImage(Uint8List.fromList(img.encodeJpg(widget.image))),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _isSelectingROI
                    ? CustomPaint(
                        painter: ROISelectorPainter(_roiRect),
                      )
                    : Container(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleROISelection,
              child: Text(_isSelectingROI ? 'Done' : 'Select ROI'),
            ),
            const SizedBox(height: 20),
            if (_croppedImage != null)
              Image.memory(Uint8List.fromList(img.encodeJpg(_croppedImage!))),
          ],
        ),
      ),
    );
  }
}

class ROISelectorPainter extends CustomPainter {
  final Rect roiRect;

  ROISelectorPainter(this.roiRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    if (!roiRect.isEmpty) {
      canvas.drawRect(roiRect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
