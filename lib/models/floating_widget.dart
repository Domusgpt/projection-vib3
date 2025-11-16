import 'package:flutter/material.dart';
import '../utils/vib3_theme.dart';

/// Represents a floating control widget
class FloatingWidget {
  final String id;
  final String title;
  final VIB3ControlCategory category;
  final Widget content;
  final Offset position;
  final Size size;
  final bool isMinimized;
  final bool snapToEdge;

  const FloatingWidget({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.position = const Offset(100, 100),
    this.size = const Size(300, 400),
    this.isMinimized = false,
    this.snapToEdge = false,
  });

  FloatingWidget copyWith({
    String? id,
    String? title,
    VIB3ControlCategory? category,
    Widget? content,
    Offset? position,
    Size? size,
    bool? isMinimized,
    bool? snapToEdge,
  }) {
    return FloatingWidget(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      position: position ?? this.position,
      size: size ?? this.size,
      isMinimized: isMinimized ?? this.isMinimized,
      snapToEdge: snapToEdge ?? this.snapToEdge,
    );
  }

  /// Calculate snapped position based on screen size
  Offset getSnappedPosition(Size screenSize) {
    if (!snapToEdge) return position;

    final snapThreshold = 50.0;
    double x = position.dx;
    double y = position.dy;

    // Snap to left edge
    if (x < snapThreshold) {
      x = 0;
    }
    // Snap to right edge
    else if (x + size.width > screenSize.width - snapThreshold) {
      x = screenSize.width - size.width;
    }

    // Snap to top edge
    if (y < snapThreshold) {
      y = 0;
    }
    // Snap to bottom edge
    else if (y + size.height > screenSize.height - snapThreshold) {
      y = screenSize.height - size.height;
    }

    return Offset(x, y);
  }
}
