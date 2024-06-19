import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addBookScreen.dart';
import '/services/GoogleBooksService.dart';

class IsbnScanScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;

  IsbnScanScreen(
      {required this.collectionId, required this.googleBooksApiKey});

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
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        _controller = CameraController(
          firstCamera,
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _controller!.initialize();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _scanISBN() async {
    try {
      if (_controller != null) {
        final image = await _controller!.takePicture();
        setState(() {
          _scannedIsbn = '978-3-16-148410-0'; 
        });
        print("Scanned ISBN: $_scannedIsbn");

        if (_scannedIsbn != null) {
          _fetchBookDetails(_scannedIsbn!);
        } 
      }
    } catch (e) {
      print('Error scanning ISBN: $e');
    }
  }

   Future<void> _fetchBookDetails(String isbn) async {
    try {
      final book = await _googleBooksService.getBookByISBN(
          isbn, widget.googleBooksApiKey);

      if (book != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBookScreen(
              collectionId: widget.collectionId,
              googleBooksApiKey: widget.googleBooksApiKey,
              initialTitle: book.title,
              initialAuthor: book.author,
              initialIsbn: book.isbn ?? '',
              initialDescription: book.description,
              initialCategories: book.categories,
              initialPageCount: book.pageCount,
              initialPublishedDate: book.publishedDate,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Book not found for ISBN: $isbn"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error fetching book details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan ISBN')),
      body: _controller != null
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
                          child: Text('Scan'),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_photography,
                    size: 64.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'This device does not have access to the camera.',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _isbnController,
                      decoration: InputDecoration(
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
                      _fetchBookDetails(_scannedIsbn!);
                    },
                    child: Text('Find Book'),
                  ),
                ],
              ),
            ),
    );
  }
}