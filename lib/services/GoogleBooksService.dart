import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Book.dart';

class GoogleBooksService {
  Future<Book?> getBookByISBN(String isbn, String apiKey) async {
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['totalItems'] > 0) {
          final Map<String, dynamic> volumeInfo =
              jsonData['items'][0]['volumeInfo'];
          final List<dynamic> industryIdentifiers =
              volumeInfo['industryIdentifiers'] ?? [];

          String isbn10 = '';
          String isbn13 = '';
          for (var identifier in industryIdentifiers) {
            if (identifier['type'] == 'ISBN_10') {
              isbn10 = identifier['identifier'];
            } else if (identifier['type'] == 'ISBN_13') {
              isbn13 = identifier['identifier'];
            }
          }

          return Book(
            title: volumeInfo['title'] ?? '',
            author: volumeInfo['authors'] != null &&
                    volumeInfo['authors'].isNotEmpty
                ? volumeInfo['authors'][0]
                : '',
            isbn: isbn10.isNotEmpty ? isbn10 : isbn13,
            description: volumeInfo['description'] ?? '',
            categories: volumeInfo['categories'] != null &&
                    volumeInfo['categories'].isNotEmpty
                ? volumeInfo['categories'].join(', ')
                : '',
            pageCount: volumeInfo['pageCount'] ?? 0,
            imageUrl: volumeInfo['imageLinks'] != null
                ? volumeInfo['imageLinks']['thumbnail'] ?? ''
                : '',
            publishedDate: _parsePublishedDate(volumeInfo['publishedDate']),
          );
        }
      }
      return null; // No book found or API error
    } catch (e) {
      print('Error fetching book data: $e');
      return null;
    }
  }

  Timestamp? _parsePublishedDate(String? dateString) {
    if (dateString == null) {
      return null;
    }
    try {
      DateTime? parsedDate;
      if (dateString.length == 4) {
        parsedDate = DateTime(int.parse(dateString));
      } else if (dateString.length == 7) {
        parsedDate = DateTime.parse('${dateString}-01');
      } else {
        parsedDate = DateTime.parse(dateString);
      }

      // Convert DateTime to Timestamp
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }
}