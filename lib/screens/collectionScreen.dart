import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addBookScreen.dart';
import '../models/book.dart';
import 'isbnScanScreen.dart';
import 'bookDetailsScreen.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionId;
  final String googleBooksApiKey;

  const CollectionScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
      ),
      body: _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookDialog(context),
        child: const Icon(Icons.add),
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
          return const Center(child: Text('No books in this collection yet.'));
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
      leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
          ? Image.network(book.imageUrl!)
          : const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Text('${book.author} - Pages: ${book.pageCount}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
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
          title: const Text('Add Book'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('How would you like to add a book?'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToManualAddBookScreen(context);
                      },
                      child: const Text('Write Manual Data'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToIsbnScanScreen(context);
                      },
                      child: const Text('ISBN Scan'),
                    ),
                  ],
                )
              ],
            ),
          ),
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
        ),
      ),
    );
  }
}