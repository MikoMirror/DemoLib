import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/firestore_service.dart';

class DeleteBookDialog extends StatelessWidget {
  final Book book;
  final String collectionId;
  final FirestoreService firestoreService;

  const DeleteBookDialog({
    super.key,
    required this.book,
    required this.collectionId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Book"),
      content: const Text("Are you sure you want to delete this book?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                try {
                  await firestoreService.removeBook(collectionId, book.id!);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book and its cover image deleted successfully')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting book: ${e.toString()}')),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}