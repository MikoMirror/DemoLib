import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_form_screen.dart';
import '../models/book.dart';
import 'isb_scan_screen.dart';
import 'book_details_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dialogs/delete_book_dialog.dart';
import '../services/firestore_service.dart';
import '../widgets/dialogs/add_book_dialog.dart';
import '../widgets/book_image_widget.dart';
import '../widgets/action_button.dart';
import 'dart:async';

class CollectionScreen extends StatefulWidget {
  final String collectionId;
  final String googleBooksApiKey;
  final FirestoreService _firestoreService = FirestoreService();

  CollectionScreen({
    required this.collectionId,
    required this.googleBooksApiKey,
    super.key,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce; 

  void _handleSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(
      title: 'Collection',
      onSearch: _handleSearch,
    ),
    body: _buildBookList(),
    floatingActionButton: ActionButton(
      onPressed: () => _showAddBookDialog(context),
    ),
  );
}
  Widget _buildBookList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('collections')
        .doc(widget.collectionId)
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
        var books = snapshot.data!.docs
            .map((doc) => Book.fromFirestore(doc))
            .where((book) =>
                book.title.toLowerCase().contains(_searchQuery) ||
                book.author.toLowerCase().contains(_searchQuery))
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1600) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              controller: _scrollController, 
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio:
                    (constraints.maxWidth / crossAxisCount) / 200,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return _buildBookCard(context, book);
              },
            );
          },
        );
      }
    },
  );
}

Widget _buildBookCard(BuildContext context, Book book) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () => _navigateToBookDetail(context, book),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookImageWidget(
                  book: book,
                  width: 120,
                  height: 180,
                ),
                const SizedBox(width: 8),
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
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showDeleteBookDialog(context, book),
                            child: const Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Text(
                          book.author,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pages: ${book.pageCount > 0 ? book.pageCount : 'Unknown'}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.0),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          book.description,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.0),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          collectionId: widget.collectionId,
          firestoreService: widget._firestoreService,
        );
      },
    );
  }

  void _navigateToManualAddBookScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookFormScreen(
          collectionId: widget.collectionId,
          googleBooksApiKey: widget.googleBooksApiKey,
          mode: FormMode.add,
        ),
      ),
    );
  }

  void _navigateToIsbnScanScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IsbnScanScreen(
          collectionId: widget.collectionId,
          googleBooksApiKey: widget.googleBooksApiKey,
        ),
      ),
    );
  }

  void _navigateToBookDetail(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(
          collectionId: widget.collectionId,
          bookId: book.id!,
          googleBooksApiKey: widget.googleBooksApiKey,
        ),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
        });
      }
    });
  }
}