import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String field;
  final bool isNumeric;
  final Function(String) onExtract;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.field,
    this.isNumeric = false,
    required this.onExtract,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.teal),
          onPressed: () => onExtract(field),
        ),
      ],
    );
  }
}
