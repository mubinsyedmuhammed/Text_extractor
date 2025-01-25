// widgets/text_field_with_extraction.dart
import 'package:flutter/material.dart';

class TextFieldWithExtraction extends StatelessWidget {
  final String label;
  final String field;
  final Function(String) onExtract;

  const TextFieldWithExtraction({
    super.key,
    required this.label,
    required this.field,
    required this.onExtract,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.teal),
          onPressed: () => onExtract(controller.text),
        ),
      ],
    );
  }
}
