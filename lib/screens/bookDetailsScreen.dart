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
            if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
              Image.network(
                book.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else 
              const SizedBox(height: 16), 

            const SizedBox(height: 16),
            Text('Author: ${book.author}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ISBN: ${book.isbn ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Pages: ${book.pageCount}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Categories: ${book.categories}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Description:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.description), 
          ],
        ),
      ),
    );
  }
}