import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class ImageService {
  static Widget getImage(String? imageUrl, {double? height, double? width}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _getPlaceholderImage(height: height, width: width);
    }

    if (kIsWeb) {
      return _getWebImage(imageUrl, height: height, width: width);
    } else {
      return _getNativeImage(imageUrl, height: height, width: width);
    }
  }

  static Widget _getWebImage(String imageUrl, {double? height, double? width}) {
    String imageId = 'img_${DateTime.now().millisecondsSinceEpoch}';
    
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        imageId,
        (int viewId) => html.ImageElement()
          ..src = imageUrl
          ..style.height = '100%'
          ..style.width = 'auto'
          ..style.objectFit = 'contain'
          ..style.maxWidth = '100%');

    return Container(
      height: height,
      width: width,
      child: HtmlElementView(
        viewType: imageId,
      ),
    );
  }

  static Widget _getNativeImage(String imageUrl, {double? height, double? width}) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print("Native image error: $error");
        return _getPlaceholderImage(height: height, width: width);
      },
    );
  }

  static Widget _getPlaceholderImage({double? height, double? width}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
      ),
    );
  }
}