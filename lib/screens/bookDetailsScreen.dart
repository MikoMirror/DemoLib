import 'package:flutter/material.dart';
import '../models/book.dart'; 
import '../widgets/CustomAppBar.dart';
import '../widgets/bookImageWidget.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const BookDetailsScreen({
    Key? key,
    required this.book,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book Details',
        isDarkMode: isDarkMode,
        onThemeToggle: onThemeToggle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookCoverAndTitle(context),
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
      ),
    );
  }

  Widget _buildBookCoverAndTitle(BuildContext context) {
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