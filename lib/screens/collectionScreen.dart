import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addBookScreen.dart';
import '../models/book.dart';
import 'isbnScanScreen.dart';
import 'bookDetailsScreen.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/StylizedButton.dart';
import '../services/ImageService.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CollectionScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    required this.isDarkMode,
    required this.onThemeToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Collection',
        isDarkMode: isDarkMode,
        onThemeToggle: onThemeToggle,
      ),
      body: _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) { 
            _showAddBookDialog(context);
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No books in this collection yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final book = Book.fromFirestore(snapshot.data!.docs[index]);
              return _buildBookListTile(context, book);
            },
          );
        }
      },
    );
  }

  ListTile _buildBookListTile(BuildContext context, Book book) {
  return ListTile(
    leading: SizedBox(
      width: 50,
      height: 75,
      child: ImageService.getImage(
        book.imageUrl,
        width: 50,
        height: 75,
      ),
    ),
    title: Text(book.title, style: Theme.of(context).textTheme.titleMedium),
    subtitle: Text('${book.author} - Pages: ${book.pageCount}',
        style: Theme.of(context).textTheme.bodyMedium),
    onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              book: book,
              isDarkMode: isDarkMode,
              onThemeToggle: onThemeToggle,
            ),
          ),
        );
      },
    );
  }

  
  Future<void> _showAddBookDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Book', style: Theme.of(context).textTheme.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('How would you like to add a book?',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: StylizedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToManualAddBookScreen(context);
                      },
                      text: 'Write Manual',
                      width: 150, // Set a constrained width
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: StylizedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToIsbnScanScreen(context);
                      },
                      text: 'ISBN Scan',
                      width: 150, // Set a constrained width
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
      );
    },
  );
}

  void _navigateToManualAddBookScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddBookScreen(
          collectionId: collectionId,
          googleBooksApiKey: googleBooksApiKey,
          isDarkMode: isDarkMode,
          onThemeToggle: onThemeToggle,
        ),
      ),
    );
  }

  void _navigateToIsbnScanScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IsbnScanScreen(
          collectionId: collectionId,
          googleBooksApiKey: googleBooksApiKey,
          isDarkMode: isDarkMode,
          onThemeToggle: onThemeToggle,
        ),
      ),
    );
  }
}