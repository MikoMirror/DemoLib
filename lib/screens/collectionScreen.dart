import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addBookScreen.dart';
import '../models/book.dart';
import 'isbnScanScreen.dart';
import 'bookDetailsScreen.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/StylizedButton.dart';
import '../widgets/dialogs/deleteBookDialog.dart';
import '../services/imgLoader/ImageService.dart';
import '../services/FirestoreService.dart';
import '../widgets/dialogs/AddBookDialog.dart';
import '../widgets/bookImageWidget.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final FirestoreService _firestoreService = FirestoreService();

  CollectionScreen({
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
      child: BookImageWidget(
        book: book,
        width: 50,
        height: 75,
      ),
    ),
    title: Text(book.title, style: Theme.of(context).textTheme.titleMedium),
    subtitle: Text('${book.author} - Pages: ${book.pageCount}',
        style: Theme.of(context).textTheme.bodyMedium),
    trailing: IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteBookDialog(context, book),
    ),
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
      return AddBookDialog(
        onManualAdd: () => _navigateToManualAddBookScreen(context),
        onIsbnScan: () => _navigateToIsbnScanScreen(context),
      );
    },
  );
}

 void _showDeleteBookDialog(BuildContext context, Book book) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DeleteBookDialog(
        book: book,
        collectionId: collectionId,
        firestoreService: _firestoreService,
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