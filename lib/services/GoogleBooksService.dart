import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<Book?> getBookByISBN(String isbn, String apiKey) async {
    final url = '$_baseUrl?q=isbn:$isbn&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return _extractBookDataFromJson(response.body);
      } else {
        print('Google Books API request failed. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching book data: $e');
      return null;
    }
  }

  Book? _extractBookDataFromJson(String jsonResponse) {
    final Map<String, dynamic> jsonData = json.decode(jsonResponse);

    if (jsonData['totalItems'] > 0) {
      final volumeInfo = jsonData['items'][0]['volumeInfo'];
      String? isbn = _extractIsbn(volumeInfo['industryIdentifiers']);

      return Book(
        title: volumeInfo['title'] ?? '',
        author: (volumeInfo['authors'] != null && volumeInfo['authors'].isNotEmpty)
                ? volumeInfo['authors'][0] 
                : '',
        isbn: isbn,
        description: volumeInfo['description'] ?? '',
        categories: (volumeInfo['categories'] != null && volumeInfo['categories'].isNotEmpty)
                ? volumeInfo['categories'].join(', ')
                : '',
        pageCount: volumeInfo['pageCount'] ?? 0,
        imageUrl: volumeInfo['imageLinks'] != null 
                ? volumeInfo['imageLinks']['thumbnail'] ?? ''
                : '',
        publishedDate: _parsePublishedDate(volumeInfo['publishedDate']),
      );
    } else {
      return null;
    }
  }

  String? _extractIsbn(List<dynamic>? identifiers) {
    if (identifiers != null) {
      for (var identifier in identifiers) {
        if (identifier['type'] == 'ISBN_13') {
          return identifier['identifier'];
        }
      }
      for (var identifier in identifiers) {
        if (identifier['type'] == 'ISBN_10') {
          return identifier['identifier'];
        }
      }
    }
    return null;
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
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }
}