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

  CollectionScreen(
      {required this.collectionId, required this.googleBooksApiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('collections')
            .doc(collectionId)
            .collection('books')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No books in this collection yet.'));
          } else {
            return ListView.builder(
             itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Book book = Book.fromFirestore(snapshot.data!.docs[index]);
                return ListTile(
                 leading: book.imageUrl != null && book.imageUrl!.isNotEmpty 
                  ? Image.network(book.imageUrl!)
                  : Icon(Icons.book), 
                title: Text(book.title),
                subtitle: Text('${book.author} - Pages: ${book.pageCount.toString()}'),  
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(book: book), // Pass the book object
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Book'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('How would you like to add a book?'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddBookScreen(
                                    collectionId: collectionId,
                                    googleBooksApiKey: googleBooksApiKey,
                                  ),
                                ),
                              );
                            },
                            child: Text('Write Manual Data'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => IsbnScanScreen(
                                      collectionId: collectionId,
                                      googleBooksApiKey: googleBooksApiKey),
                                ),
                              );
                            },
                            child: Text('ISBN Scan'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}