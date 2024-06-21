import 'package:flutter/material.dart';
import '../services/FirestoreService.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/StylizedButton.dart';
import '../widgets/stylizedTextField.dart';

class AddCollectionScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AddCollectionScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  AddCollectionScreenState createState() => AddCollectionScreenState();
}

class AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _firestoreService.addCollection(
        _nameController.text,
        _descriptionController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Collection',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            
              StylizedTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) => 
                  value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _descriptionController,
                labelText: 'Description',
              ),
              const SizedBox(height: 24),
              StylizedButton(
                onPressed: _submitForm,
                text: 'Add Collection',
              ),
            ],
          ),
        ),
      ),
    );
  }
}