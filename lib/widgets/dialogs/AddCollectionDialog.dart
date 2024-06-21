import 'package:flutter/material.dart';
import '../../services/FirestoreService.dart';
import '../StylizedTextField.dart';
import '../StylizedButton.dart';

class AddCollectionDialog extends StatefulWidget {
  final bool isDarkMode;

  const AddCollectionDialog({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _AddCollectionDialogState createState() => _AddCollectionDialogState();
}

class _AddCollectionDialogState extends State<AddCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

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
    return AlertDialog(
      title: Text('Add Collection', style: Theme.of(context).textTheme.headlineSmall),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        StylizedButton(
          onPressed: _submitForm,
          text: 'Add Collection',
        ),
      ],
      backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
    );
  }
}