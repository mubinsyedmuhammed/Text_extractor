import 'package:flutter/material.dart';
import 'package:text_extractor/widgets/text_field_widget.dart';

class ROIForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> fieldControllers;
  final Function(String field) onExtract;
  final VoidCallback onSubmit;

  const ROIForm({
    super.key,
    required this.formKey,
    required this.fieldControllers,
    required this.onExtract,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          for (var entry in fieldControllers.entries)
            TextFieldWidget(
              controller: entry.value,
              label: entry.key,
              field: entry.key,
              onExtract: onExtract,
            ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed: onSubmit, child: const Text("Submit")),
        ],
      ),
    );
  }
}

