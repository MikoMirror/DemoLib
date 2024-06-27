import 'package:flutter/material.dart';

class StylizedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;  // Add this line
  const StylizedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.enabled = true,  // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,  // Add this line
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(  // Add this block
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).disabledColor),
        ),
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }
}