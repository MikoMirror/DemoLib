import 'package:flutter/material.dart';
import '../models/book.dart'; 
import '../widgets/CustomAppBar.dart';
import '../services/imageService.dart';

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
            _buildBookCoverImage(context),
            const SizedBox(height: 16),
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

  Widget _buildBookCoverImage(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double imageHeight = screenHeight * 0.4;

  return Container(
    height: imageHeight,
    width: double.infinity,
    alignment: Alignment.center,
    child: ImageService.getImage(
      book.imageUrl,
      height: imageHeight,
      width: null, // Set to null to allow the image to determine its own width
    ), // Center the image within the container
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