import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? isbn;
  final String title;
  final String author;
  final String description;
  final String categories; 
  final int pageCount;
  final DateTime? publishedDate;

  Book({
    this.isbn,
    required this.title,
    required this.author,
    this.description = '', 
    this.categories = '', 
    this.pageCount = 0,   
    this.publishedDate, 
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      isbn: data['isbn'],
      title: data['title'] ?? '', 
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      categories: data['categories'] ?? '',
      pageCount: int.tryParse(data['page_count'] ?? '0') ?? 0,
      publishedDate: (data['published_date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
      'description': description,
      'categories': categories,
      'page_count': pageCount.toString(),
      'published_date': publishedDate,
    };
  }
}