import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/dialogs/AddCollectionDialog.dart';
import '../widgets/dialogs/DeleteCollectionDialog.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Collections',
        isDarkMode: isDarkMode,
        onThemeToggle: onThemeToggle,
      ),
      body: _buildBody(context, user),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCollectionDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildBody(BuildContext context, User? user) {
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  doc['name'],
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => _showDeleteCollectionDialog(context, user.uid, doc.id),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/collection',
                    arguments: doc.id,
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCollectionDialog(isDarkMode: isDarkMode);
      },
    );
  }

  void _showDeleteCollectionDialog(BuildContext context, String userId, String collectionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteCollectionDialog(
          userId: userId,
          collectionId: collectionId,
        );
      },
    );
  }
}