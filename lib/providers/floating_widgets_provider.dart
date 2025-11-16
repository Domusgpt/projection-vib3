import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/floating_widget.dart';

class FloatingWidgetsState {
  final List<FloatingWidget> widgets;
  final String? activeWidgetId; // Currently being dragged

  const FloatingWidgetsState({
    this.widgets = const [],
    this.activeWidgetId,
  });

  FloatingWidgetsState copyWith({
    List<FloatingWidget>? widgets,
    String? activeWidgetId,
    bool clearActive = false,
  }) {
    return FloatingWidgetsState(
      widgets: widgets ?? this.widgets,
      activeWidgetId: clearActive ? null : (activeWidgetId ?? this.activeWidgetId),
    );
  }
}

class FloatingWidgetsNotifier extends StateNotifier<FloatingWidgetsState> {
  FloatingWidgetsNotifier() : super(const FloatingWidgetsState());

  /// Add a new floating widget
  void addWidget(FloatingWidget widget) {
    final newWidgets = List<FloatingWidget>.from(state.widgets);

    // Remove existing widget with same ID if present
    newWidgets.removeWhere((w) => w.id == widget.id);

    newWidgets.add(widget);
    state = state.copyWith(widgets: newWidgets);
  }

  /// Remove a floating widget by ID
  void removeWidget(String id) {
    final newWidgets = state.widgets.where((w) => w.id != id).toList();
    state = state.copyWith(widgets: newWidgets);
  }

  /// Update widget position
  void updatePosition(String id, Offset newPosition) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        return w.copyWith(position: newPosition);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: newWidgets);
  }

  /// Toggle minimize state
  void toggleMinimize(String id) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        return w.copyWith(isMinimized: !w.isMinimized);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: newWidgets);
  }

  /// Toggle snap to edge
  void toggleSnapToEdge(String id) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        return w.copyWith(snapToEdge: !w.snapToEdge);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: newWidgets);
  }

  /// Set active widget (being dragged)
  void setActiveWidget(String? id) {
    state = state.copyWith(activeWidgetId: id, clearActive: id == null);
  }

  /// Bring widget to front (reorder)
  void bringToFront(String id) {
    final widget = state.widgets.firstWhere((w) => w.id == id);
    final newWidgets = state.widgets.where((w) => w.id != id).toList();
    newWidgets.add(widget); // Add to end (top of stack)
    state = state.copyWith(widgets: newWidgets);
  }

  /// Snap all widgets to edges
  void snapAllToEdges(Size screenSize) {
    final newWidgets = state.widgets.map((w) {
      if (w.snapToEdge) {
        final snappedPosition = w.getSnappedPosition(screenSize);
        return w.copyWith(position: snappedPosition);
      }
      return w;
    }).toList();
    state = state.copyWith(widgets: newWidgets);
  }

  /// Clear all floating widgets
  void clearAll() {
    state = const FloatingWidgetsState();
  }
}

final floatingWidgetsProvider =
    StateNotifierProvider<FloatingWidgetsNotifier, FloatingWidgetsState>((ref) {
  return FloatingWidgetsNotifier();
});
