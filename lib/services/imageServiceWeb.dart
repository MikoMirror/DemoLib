import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Widget getPlatformImage(String imageUrl, {double? height, double? width}) {
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