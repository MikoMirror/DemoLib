import 'package:flutter/material.dart';
import '../services/FirestoreService.dart';

class AddCollectionScreen extends StatefulWidget {
  @override
  _AddCollectionScreenState createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService(); 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _firestoreService.addCollection(
          _nameController.text, _descriptionController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Collection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Add Collection'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}