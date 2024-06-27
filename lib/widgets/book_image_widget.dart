import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/google_books_service.dart';

class BookImageWidget extends StatelessWidget {
  final Book book;
  final double? width;
  final double? height;
  final String? isbn;

  const BookImageWidget({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.isbn,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = book.externalImageUrl ?? 
        (isbn != null ? GoogleBooksService.getOpenLibraryCoverUrl(isbn!, 'L') : '');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'img/cover.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}