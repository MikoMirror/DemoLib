import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';

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
    if (_userId == null) {
      throw Exception("User not logged in");
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .add(book.toFirestore());
    } catch (e) {
      print('Error adding book: $e');
      throw Exception('Failed to add book: $e');
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

 Future<void> removeCollection(String collectionId) async {
    if (_userId != null) {
      QuerySnapshot booksSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .get();
      for (var doc in booksSnapshot.docs) {
        await removeBook(collectionId, doc.id);
      }
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .delete();
    } else {
      print("Error: User not logged in while removing collection");
    }
  }

  Future<void> removeBook(String collectionId, String bookId) async {
    if (_userId == null) {
      throw Exception("User not logged in");
    }
  
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc(collectionId)
          .collection('books')
          .doc(bookId)
          .delete();

      print("Book document deleted successfully");
    } catch (e) {
      print("Error removing book: $e");
      throw Exception("Failed to remove book: $e");
    }
  }
}