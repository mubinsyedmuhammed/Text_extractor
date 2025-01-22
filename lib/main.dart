import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

/// The main function initializes the Flutter application
/// and runs the MyApp widget.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
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
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Row(
        children: const [
          Expanded(child: PersonalInfoForm()),
          Expanded(child: FileUploader()),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueGrey,
      centerTitle: true,
      title: const Text(
        "Home Page",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  PersonalInfoFormState createState() => PersonalInfoFormState();
}

class PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final FormFieldControllers _controllers = FormFieldControllers();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blueGrey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Text(
              "Personal Information",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                ..._controllers.buildFormFields(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form Submitted Successfully')),
      );
    }
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextFormField(
      {super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $label';
                }
                return null;
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.crop),
            onPressed: () {
              print('Selecting ROI for $label');
            },
          ),
        ],
      ),
    );
  }
}

class FormFieldControllers {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  List<Widget> buildFormFields() {
    return [
      CustomTextFormField(controller: nameController, label: 'Name'),
      CustomTextFormField(controller: emailController, label: 'Email'),
      CustomTextFormField(controller: ageController, label: 'Age'),
      CustomTextFormField(controller: phoneController, label: 'Phone number'),
      CustomTextFormField(controller: addressController, label: 'Address'),
    ];
  }
}

class FileUploader extends StatefulWidget {
  final double width;
  final double height;

  const FileUploader({Key? key, this.width = 100, this.height = 500})
      : super(key: key);

  @override
  FileUploaderState createState() => FileUploaderState();
}

class FileUploaderState extends State<FileUploader> {
  Uint8List? _imageBytes;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _imageBytes == null
            ? Center(
                child: Text(
                  'Tap to upload\nimage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey[500]),
                ),
              )
            : InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: 1.0,
                maxScale: 5.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _imageBytes!,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      ),
    );
  }
}
