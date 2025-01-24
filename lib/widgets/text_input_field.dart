import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumeric;

  const TextInputField({
    super.key,
    required this.controller,
    required this.label,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
    );
  }
}
