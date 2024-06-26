import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '/services/GoogleBooksService.dart';
import 'BookFormScreen.dart';
import '../widgets/CustomAppBar.dart';

class IsbnScanScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const IsbnScanScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    required this.isDarkMode,
    required this.onThemeToggle,
    super.key,
  });

  @override
  _IsbnScanScreenState createState() => _IsbnScanScreenState();
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

      if (book != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookFormScreen(
              collectionId: widget.collectionId,
              googleBooksApiKey: widget.googleBooksApiKey,
              book: book,
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle,
              mode: FormMode.add,
            ),
          ),
        );
      } else {
        _showBookNotFoundErrorDialog(isbn);
      }
    } catch (e) {
      print("Error fetching book details: $e");
      _showErrorDialog("Error fetching book details: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Scan ISBN',
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isbnController.text.isNotEmpty) {
                    _fetchBookDetails(_isbnController.text);
                  }
                },
                child: const Text('Find Book'),
              ),
              SizedBox(height: 20),
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