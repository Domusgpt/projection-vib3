import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/floating_widgets_provider.dart';
import 'draggable_floating_widget.dart';

/// Overlay that displays all floating widgets
class FloatingWidgetsOverlay extends ConsumerWidget {
  const FloatingWidgetsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(floatingWidgetsProvider);

    if (state.widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: state.widgets
            .map((widget) => DraggableFloatingWidget(widget: widget))
            .toList(),
      ),
    );
  }
}
