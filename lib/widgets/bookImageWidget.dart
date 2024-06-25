import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookImageWidget extends StatelessWidget {
  final Book book;
  final double? width;
  final double? height;

  const BookImageWidget({
    Key? key,
    required this.book,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: book.externalImageUrl ?? '',
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(Icons.book, color: Colors.grey[600]),
      ),
    );
  }
}