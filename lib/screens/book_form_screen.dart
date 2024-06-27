import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/stylized_button.dart';
import '../widgets/book_image_widget.dart';
import '../services/theme_provider.dart';

enum FormMode { add, edit }

class BookFormScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final Book? book;
  final FormMode mode;

  const BookFormScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    this.book,
    required this.mode,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookFormScreenState createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoriesController;
  late TextEditingController _pageCountController;
  late TextEditingController _publishedDateController;

  Timestamp? _selectedDate;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  void _initializeControllers() {
    final book = widget.book;

    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _descriptionController = TextEditingController(text: book?.description ?? '');
    _categoriesController = TextEditingController(text: book?.categories ?? '');
    _pageCountController = TextEditingController(text: book?.pageCount.toString() ?? '');

    _selectedDate = book?.publishedDate;
    _imageUrl = book?.externalImageUrl;
    _publishedDateController = TextEditingController(
      text: book?.publishedDate != null
          ? DateFormat('yyyy-MM-dd').format(book!.publishedDate!.toDate())
          : '',
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate?.toDate() ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate?.toDate()) {
      setState(() {
        _selectedDate = Timestamp.fromDate(picked);
        _publishedDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    Book bookData = Book(
      id: widget.mode == FormMode.edit ? widget.book!.id : null,
      title: _titleController.text,
      author: _authorController.text,
      isbn: _isbnController.text,
      description: _descriptionController.text,
      categories: _categoriesController.text,
      pageCount: int.tryParse(_pageCountController.text) ?? 0,
      publishedDate: _selectedDate,
      externalImageUrl: _imageUrl,
    );

    try {
      if (widget.mode == FormMode.edit) {
        await _firestoreService.updateBook(widget.collectionId, bookData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );
      } else {
        await _firestoreService.addBook(widget.collectionId, bookData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully')),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${widget.mode == FormMode.edit ? 'update' : 'add'} book: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    ThemeProvider.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.mode == FormMode.edit ? 'Edit Book' : 'Add Book',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              BookImageWidget(
                book: Book(
                  title: _titleController.text,
                  author: _authorController.text,
                  externalImageUrl: _imageUrl,
                ),
                isbn: _isbnController.text,
                height: 200,
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _titleController,
                labelText: 'Title',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _authorController,
                labelText: 'Author',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an author'
                    : null,
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _isbnController,
                labelText: 'ISBN',
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _descriptionController,
                labelText: 'Description',
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _categoriesController,
                labelText: 'Categories',
              ),
              const SizedBox(height: 16),
              StylizedTextField(
                controller: _pageCountController,
                labelText: 'Page Count',
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: StylizedTextField(
                    controller: _publishedDateController,
                    labelText: 'Published Date',
                    enabled: false, 
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StylizedButton(
                onPressed: _submitForm,
                text: widget.mode == FormMode.edit ? 'Update Book' : 'Add Book',
              ),
            ],
          ),
        ),
      ),
    );
  }
}