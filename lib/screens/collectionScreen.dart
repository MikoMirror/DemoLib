import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addBookScreen.dart';
import '../models/book.dart';
import 'isbnScanScreen.dart';
import 'bookDetailsScreen.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/dialogs/deleteBookDialog.dart';
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
            return _buildBookCard(context, book);
          },
        );
      }
    },
  );
}

Widget _buildBookCard(BuildContext context, Book book) {
  return Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: InkWell(
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
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookImageWidget(
              book: book,
              width: 80,
              height: 120,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showDeleteBookDialog(context, book),
                        child: Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  Text(
                    book.author,
                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.0),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pages: ${book.pageCount > 0 ? book.pageCount : 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.0),
                  ),
                  SizedBox(height: 12),
                  Text(
                    book.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
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