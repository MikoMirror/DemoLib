import 'package:flutter/material.dart';
import '../models/book.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/book_image_widget.dart';
import '../services/firestore_service.dart';
import 'book_form_screen.dart';
import '../services/theme_provider.dart';

class BookDetailsScreen extends StatelessWidget {
  final String collectionId;
  final String bookId;
  final String googleBooksApiKey;

  const BookDetailsScreen({
    super.key,
    required this.collectionId,
    required this.bookId,
    required this.googleBooksApiKey,
  });

  @override
  Widget build(BuildContext context) {
    return _BookDetailsScreenContent(
      collectionId: collectionId,
      bookId: bookId,
      googleBooksApiKey: googleBooksApiKey,
    );
  }
}

class _BookDetailsScreenContent extends StatefulWidget {
  final String collectionId;
  final String bookId;
  final String googleBooksApiKey;

  const _BookDetailsScreenContent({
    required this.collectionId,
    required this.bookId,
    required this.googleBooksApiKey,
  });

  @override
  _BookDetailsScreenContentState createState() => _BookDetailsScreenContentState();
}

class _BookDetailsScreenContentState extends State<_BookDetailsScreenContent> {
  late Future<Book> _bookFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _bookFuture = _loadBook();
  }

  Future<Book> _loadBook() async {
    return await _firestoreService.getBook(widget.collectionId, widget.bookId);
  }

  void _refreshBookDetails() {
    setState(() {
      _bookFuture = _loadBook();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
        ],
      ),
      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No book data available'));
          }

          final book = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookCoverAndTitle(context, book),
                const SizedBox(height: 24),
                _buildBookDetailRow('Author:', book.author),
                _buildBookDetailRow('ISBN:', book.isbn ?? 'N/A'),
                _buildBookDetailRow('Pages:', book.pageCount.toString()),
                _buildBookDetailRow('Categories:', book.categories),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(book.description),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    _bookFuture.then((book) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookFormScreen(
            collectionId: widget.collectionId,
            googleBooksApiKey: widget.googleBooksApiKey,
            book: book,
            mode: FormMode.edit,
          ),
        ),
      ).then((value) {
        if (value == true) {
          _refreshBookDetails();
        }
      });
    });
  }

  Widget _buildBookCoverAndTitle(BuildContext context, Book book) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.4;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color solidColor = isDarkMode ? Colors.white : const Color.fromARGB(255, 48, 48, 48);
    return Column(
      children: [
        Container(
          height: imageHeight,
          width: double.infinity,
          alignment: Alignment.center,
          child: BookImageWidget(
            book: book,
            height: imageHeight,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                solidColor.withOpacity(0.0),
                solidColor,
                solidColor.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          book.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label $value', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
      ],
    );
  }
}