import 'package:flutter/material.dart';

Widget getPlatformImage(String imageUrl, {double? height, double? width}) {
  return Image.network(
    imageUrl,
    height: height,
    width: width,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      print("Native image error: $error");
      return Container(
        height: height,
        width: width,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
        ),
      );
    },
  );
}