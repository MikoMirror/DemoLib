import 'package:flutter/material.dart';
import '/services/FirestoreService.dart';
import '/models/book.dart';
import 'package:intl/intl.dart'; 

class AddBookScreen extends StatefulWidget {
  final String collectionId;

  AddBookScreen({required this.collectionId});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _publishedDateController =
      TextEditingController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _publishedDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _categoriesController.dispose();
    _pageCountController.dispose();
    _publishedDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _publishedDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

 void _submitForm() {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    Book newBook = Book(
      title: _titleController.text,
      author: _authorController.text,
      isbn: _isbnController.text,
      description: _descriptionController.text,
      categories: _categoriesController.text,
      pageCount: int.tryParse(_pageCountController.text) ?? 0,
      publishedDate: _selectedDate, 
    );
    _firestoreService.addBook(widget.collectionId, newBook);
    _formKey.currentState!.reset();
    Navigator.of(context).pop(); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Book')),
      body: SingleChildScrollView( 
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an author' : null,
              ),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(labelText: 'ISBN'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _categoriesController,
                decoration: InputDecoration(labelText: 'Categories'),
              ),
              TextFormField(
                controller: _pageCountController,
                decoration: InputDecoration(labelText: 'Page Count'),
                keyboardType: TextInputType.number,
              ),
              // Date Picker
              TextField(
                controller: _publishedDateController,
                decoration: InputDecoration(
                  labelText: 'Published Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Add Book'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}