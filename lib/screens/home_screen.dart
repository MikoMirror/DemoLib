import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dialogs/add_collection_dialog.dart';
import '../widgets/dialogs/delete_collection_dialog.dart';
import '../services/theme_provider.dart';
import '../widgets/action_button.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeScreen({super.key});

  @override
Widget build(BuildContext context) {
  final User? user = _auth.currentUser;
  ThemeProvider.of(context);
  return Scaffold(
    appBar: CustomAppBar(
      title: 'My Collections',
      onBackPressed: () => _handleBackPress(context),
    ),
    body: _buildBody(context, user),
    floatingActionButton: ActionButton(
      onPressed: () => _showAddCollectionDialog(context),
      tooltip: 'Add new collection',
      child: const Icon(Icons.add),
    ),
  );
}

  void _handleBackPress(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Do you want to log out?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
              TextButton(
                child: const Text('Log Out'),
                onPressed: () {
                  _auth.signOut();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
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
        return const AddCollectionDialog();
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