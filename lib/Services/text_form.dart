import 'package:flutter/material.dart';


class IconButtonForText extends StatelessWidget {
  const IconButtonForText({super.key, required this.field, required this.onExtract});

  final String field;
  final Function(String) onExtract;

  @override
  Widget build(BuildContext context) {
    return IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.blueGrey),
          onPressed: () => onExtract(field),
        );
  }
}

// ignore: use_key_in_widget_constructors
class CustomForm extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _clearField(TextEditingController controller) {
    controller.clear();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form Submitted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Personal Information', style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ), 
        centerTitle: true,
      ),
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _genderController,
                label: 'Gender',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.text_fields,
              ),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.text_fields,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(icon),
            onPressed: () => _clearField(controller),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
