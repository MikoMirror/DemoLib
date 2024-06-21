import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import for web vs. native (mobile and desktop/mobile)
import 'imageServiceWeb.dart' if (dart.library.io) 'imageServiceNative.dart' as platform;

class ImageService {
  static Widget getImage(String? imageUrl, {double? height, double? width}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _getPlaceholderImage(height: height, width: width);
    }
    if (kIsWeb) {
      return platform.getPlatformImage(imageUrl, height: height, width: width);
    } else {
      return _getNativeImage(imageUrl, height: height, width: width);
    }
  }

  static Widget _getNativeImage(String imageUrl, {double? height, double? width}) {
    return platform.getPlatformImage(imageUrl, height: height, width: width);
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