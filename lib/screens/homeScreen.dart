import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'collectionScreen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Collections'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/addCollection');
            },
          ),
        ],
      ),
      body: user != null
          ? StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('collections')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['name']),
                      onTap: () {
                    
                        Navigator.pushNamed(
                          context,
                          '/collection',
                          arguments: doc.id,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            )
          : Center(child: Text('No user logged in')),
    );
  }
}