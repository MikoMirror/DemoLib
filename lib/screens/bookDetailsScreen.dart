import 'package:flutter/material.dart';
import '../models/book.dart'; 

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
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
    if (book.imageUrl != null && book.imageUrl!.isNotEmpty) {
      double screenHeight = MediaQuery.of(context).size.height;
      double imageHeight = screenHeight * 0.4; 
      return Image.network(
        book.imageUrl!,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.contain, 
      );
    } else {
      return const SizedBox(height: 16);
    }
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