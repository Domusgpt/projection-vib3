import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/floating_widget.dart';
import '../providers/floating_widgets_provider.dart';
import '../utils/vib3_theme.dart';

/// Helper class to create and manage floating widgets from tabs
class FloatingWidgetHelper {
  /// Create a floating widget from tab content
  static void pullOutWidget({
    required WidgetRef ref,
    required String id,
    required String title,
    required VIB3ControlCategory category,
    required Widget content,
    Offset? initialPosition,
    Size? size,
  }) {
    final floatingWidget = FloatingWidget(
      id: id,
      title: title,
      category: category,
      content: content,
      position: initialPosition ?? const Offset(100, 150),
      size: size ?? const Size(320, 450),
      snapToEdge: false,
      isMinimized: false,
    );

    ref.read(floatingWidgetsProvider.notifier).addWidget(floatingWidget);
  }

  /// Remove a floating widget
  static void removeWidget({
    required WidgetRef ref,
    required String id,
  }) {
    ref.read(floatingWidgetsProvider.notifier).removeWidget(id);
  }

  /// Check if a widget is currently floating
  static bool isFloating({
    required WidgetRef ref,
    required String id,
  }) {
    final state = ref.read(floatingWidgetsProvider);
    return state.widgets.any((w) => w.id == id);
  }

  /// Toggle floating state of a widget
  static void toggleFloat({
    required WidgetRef ref,
    required String id,
    required String title,
    required VIB3ControlCategory category,
    required Widget content,
    Offset? initialPosition,
    Size? size,
  }) {
    if (isFloating(ref: ref, id: id)) {
      removeWidget(ref: ref, id: id);
    } else {
      pullOutWidget(
        ref: ref,
        id: id,
        title: title,
        category: category,
        content: content,
        initialPosition: initialPosition,
        size: size,
      );
    }
  }
}
