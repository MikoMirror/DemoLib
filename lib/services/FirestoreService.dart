import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/book.dart'; 

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  String? get _userId { 
    return _auth.currentUser?.uid;
  }

  Future<void> addCollection(String name, String description) async {
    if (_userId != null) {
      await _firestore
          .collection('users')
          .doc(_userId) 
          .collection('collections')
          .add({
        'name': name,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else {
      print("Error: User not logged in while adding collection");
    }
  }

  Future<void> addBook(String collectionId, Book book) async { 
    if (_userId != null) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .add(book.toFirestore()); 
    } else {
      print("Error: User not logged in while adding book"); 
    }
  }

  Stream<QuerySnapshot> getCollections() {
    if (_userId != null) {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .snapshots();
    } else {
      throw FirebaseAuthException(
        code: 'USER_NOT_LOGGED_IN',
        message: 'User is not logged in',
      );
    }
  }

  Stream<QuerySnapshot> getBooks(String collectionId) {
    if (_userId != null) {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .snapshots();
    } else {
      throw FirebaseAuthException(
        code: 'USER_NOT_LOGGED_IN',
        message: 'User is not logged in',
      );
    }
  }
}