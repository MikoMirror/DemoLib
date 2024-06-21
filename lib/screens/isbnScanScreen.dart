import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 

import '/services/GoogleBooksService.dart';
import 'addBookScreen.dart';
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
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final TextEditingController _isbnController = TextEditingController();
  String? _scannedIsbn;

  final GoogleBooksService _googleBooksService = GoogleBooksService();

   @override
  void initState() {
    super.initState();
    if (!kIsWeb) { 
      _initializeCamera();
    }
  }


  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _scanISBN() async {
    if (_controller != null) {
      final image = await _controller!.takePicture();

      // TODO: Implement actual ISBN scanning from image

      // Placeholder ISBN for testing
      setState(() {
        _scannedIsbn = '978-3-16-148410-0';
      });

      if (_scannedIsbn != null) {
        _fetchBookDetails(_scannedIsbn!);
      }
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
          builder: (context) => AddBookScreen(
            collectionId: widget.collectionId,
            googleBooksApiKey: widget.googleBooksApiKey,
            initialBook: book,
            isDarkMode: false, // Add this line
            onThemeToggle: () {}, // Add this line
          ),
        ),
      );
    } else {
      _showBookNotFoundErrorDialog(isbn);
    }
  } catch (e) {
    print("Error fetching book details: $e");
  }
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
      body:  
         kIsWeb  
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_photography,
                    size: 64.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'ISBN scanning is not available on the web.',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'Enter ISBN manually',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scannedIsbn = _isbnController.text;
                      });
                      if (_scannedIsbn != null) {
                        _fetchBookDetails(_scannedIsbn!);
                      }
                    },
                    child: const Text('Find Book'),
                  ),
                ],
              ),
            )
          : _controller != null
              ? FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CameraPreview(_controller!),
                          Positioned(
                            bottom: 20.0,
                            child: ElevatedButton(
                              onPressed: _scanISBN,
                              child: const Text('Scan'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : const Center(
                  child: Text('Camera initialization failed.'),
                ),
    );
  }
}