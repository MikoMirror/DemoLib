import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '/services/FirestoreService.dart';
import '/models/book.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final String initialTitle;
  final String initialAuthor;
  final String initialIsbn;
  final String initialDescription;
  final String initialCategories;
  final int initialPageCount;
  final Timestamp? initialPublishedDate;

  AddBookScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    this.initialTitle = '',
    this.initialAuthor = '',
    this.initialIsbn = '',
    this.initialDescription = '',
    this.initialCategories = '',
    this.initialPageCount = 0,
    this.initialPublishedDate,
  });

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _publishedDateController = TextEditingController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController();

  Timestamp? _selectedDate;
  File? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _publishedDateController.text = widget.initialPublishedDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.initialPublishedDate!.toDate())
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    _titleController.text = widget.initialTitle;
    _authorController.text = widget.initialAuthor;
    _isbnController.text = widget.initialIsbn;
    _descriptionController.text = widget.initialDescription;
    _categoriesController.text = widget.initialCategories;
    _pageCountController.text = widget.initialPageCount.toString();
    _selectedDate = widget.initialPublishedDate;
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
      initialDate: _selectedDate?.toDate() ?? DateTime.now(), // Use toDate()
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate?.toDate()) { // Use toDate()
      setState(() {
        _selectedDate = Timestamp.fromDate(picked);
        _publishedDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('book_covers/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToStorage(_selectedImage!);
      }

      Book newBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text,
        description: _descriptionController.text,
        categories: _categoriesController.text,
        pageCount: int.tryParse(_pageCountController.text) ?? 0,
        publishedDate: _selectedDate, 
        imageUrl: imageUrl,
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
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
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
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200.0, width: 200.0)
                : Placeholder(fallbackHeight: 200.0, fallbackWidth: 200.0),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choose Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Add Book'),
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    ));
  }
}