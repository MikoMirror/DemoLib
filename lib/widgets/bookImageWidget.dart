import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/imgLoader/imageService.dart';

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
    String? imageUrl = book.localImageUrl ?? book.externalImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ImageService.getImage(
        imageUrl,
        width: width,
        height: height,
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(Icons.book, color: Colors.grey[600]),
      );
    }
  }
}