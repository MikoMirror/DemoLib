import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final double? elevation;
  final double? size;

  const ActionButton({
    super.key,
    required this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.elevation,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.purple[600], 
      foregroundColor: foregroundColor ?? Colors.white, 
      tooltip: tooltip,
      elevation: elevation ?? 6.0,
      mini: size != null && size! < 56.0,
      child: child ?? const Icon(Icons.add),
    );
  }
}