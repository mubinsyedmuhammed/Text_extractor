import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';

class ROIImageViewer extends StatelessWidget {
  final Uint8List? imageBytes;
  final ImagePainterController controller;
  final VoidCallback onPickFile;
  final VoidCallback onClearImage;

  const ROIImageViewer({
    super.key,
    required this.imageBytes,
    required this.controller,
    required this.onPickFile,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: imageBytes == null
          ? Center(
              child: ElevatedButton(
                onPressed: onPickFile,
                child: const Text("Upload Image"),
              ),
            )
          : Expanded(
              child: Stack(
                children: [
                  ImagePainter.memory(
                    imageBytes!,
                    controller: controller,
                    scalable: true,
                  ),
                  Positioned(
                    top: 60,
                    right: 6,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: IconButton(
                        onPressed: onClearImage,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
