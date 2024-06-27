import 'package:flutter/material.dart';

class StylizedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const StylizedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor ?? Colors.white,
          backgroundColor: backgroundColor ?? Colors.purple[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          padding: EdgeInsets.zero, // Remove default padding
        ),
        child: Center( // Wrap the Text with Center widget
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: foregroundColor ?? Colors.white,
            ),
            textAlign: TextAlign.center, // Ensure text is centered
          ),
        ),
      ),
    );
  }
}