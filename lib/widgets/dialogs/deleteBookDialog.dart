import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/FirestoreService.dart';

class DeleteBookDialog extends StatelessWidget {
  final Book book;
  final String collectionId;
  final FirestoreService firestoreService;

  const DeleteBookDialog({
    Key? key,
    required this.book,
    required this.collectionId,
    required this.firestoreService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete Book"),
      content: Text("Are you sure you want to delete this book?"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Delete"),
          onPressed: () async {
            try {
              await firestoreService.removeBook(collectionId, book.id!);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Book and its cover image deleted successfully')),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting book: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }
}