// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../services/google_books_service.dart';
import 'book_form_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../services/theme_provider.dart';

class IsbnScanScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;

  const IsbnScanScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    super.key,
  });

  @override
  State<IsbnScanScreen> createState() => _IsbnScanScreenState();
}

class _IsbnScanScreenState extends State<IsbnScanScreen> {
  final TextEditingController _isbnController = TextEditingController();
  final GoogleBooksService _googleBooksService = GoogleBooksService();

  Future<void> _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (barcodeScanRes != '-1') {
        _fetchBookDetails(barcodeScanRes);
      }
    } catch (e) {
      print('Failed to scan barcode: $e');
      _showErrorDialog('Failed to scan barcode: $e');
    }
  }

  Future<void> _fetchBookDetails(String isbn) async {
  try {
    final book = await _googleBooksService.getBookByISBN(
      isbn,
      widget.googleBooksApiKey,
    );
    if (!mounted) return; 

    if (book != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookFormScreen(
            collectionId: widget.collectionId,
            googleBooksApiKey: widget.googleBooksApiKey,
            book: book,
            mode: FormMode.add,
          ),
        ),
      );
    } else {
      _showBookNotFoundErrorDialog(isbn);
    }
  } catch (e) {
    if (!mounted) return; 
    print("Error fetching book details: $e");
    _showErrorDialog("Error fetching book details: $e");
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showBookNotFoundErrorDialog(String isbn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text("Book not found for ISBN: $isbn"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider.of(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Scan ISBN',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'Enter ISBN manually',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isbnController.text.isNotEmpty) {
                    _fetchBookDetails(_isbnController.text);
                  }
                },
                child: const Text('Find Book'),
              ),
              const SizedBox(height: 20),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: _scanBarcode,
                  child: const Text('Scan ISBN Barcode'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}