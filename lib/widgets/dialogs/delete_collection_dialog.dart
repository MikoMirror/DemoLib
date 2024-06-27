import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCollectionDialog extends StatelessWidget {
  final String userId;
  final String collectionId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DeleteCollectionDialog({
    super.key,
    required this.userId,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Collection"),
      content: const Text("Are you sure you want to delete this collection?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text("Delete"),
          onPressed: () => _deleteCollection(context),
        ),
      ],
    );
  }

  void _deleteCollection(BuildContext context) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('collections')
        .doc(collectionId)
        .delete()
        .then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection deleted successfully')),
      );
    }).catchError((error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete collection: $error')),
      );
    });
  }
}