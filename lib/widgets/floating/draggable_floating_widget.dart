import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/floating_widget.dart';
import '../../providers/floating_widgets_provider.dart';
import '../../utils/vib3_theme.dart';

/// Draggable floating widget container
class DraggableFloatingWidget extends ConsumerStatefulWidget {
  final FloatingWidget widget;

  const DraggableFloatingWidget({
    super.key,
    required this.widget,
  });

  @override
  ConsumerState<DraggableFloatingWidget> createState() =>
      _DraggableFloatingWidgetState();
}

class _DraggableFloatingWidgetState
    extends ConsumerState<DraggableFloatingWidget> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final position = widget.widget.snapToEdge
        ? widget.widget.getSnappedPosition(screenSize)
        : widget.widget.position;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          ref.read(floatingWidgetsProvider.notifier).bringToFront(widget.widget.id);
          ref
              .read(floatingWidgetsProvider.notifier)
              .setActiveWidget(widget.widget.id);
          _dragOffset = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_dragOffset != null) {
            final newPosition = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );

            // Clamp to screen bounds
            final clampedPosition = Offset(
              newPosition.dx.clamp(0.0, screenSize.width - widget.widget.size.width),
              newPosition.dy.clamp(0.0, screenSize.height - widget.widget.size.height),
            );

            ref
                .read(floatingWidgetsProvider.notifier)
                .updatePosition(widget.widget.id, clampedPosition);
          }
        },
        onPanEnd: (details) {
          ref.read(floatingWidgetsProvider.notifier).setActiveWidget(null);
          _dragOffset = null;

          // Snap to edge if enabled
          if (widget.widget.snapToEdge) {
            ref.read(floatingWidgetsProvider.notifier).snapAllToEdges(screenSize);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.widget.size.width,
          height: widget.widget.isMinimized ? 60 : widget.widget.size.height,
          child: GlassmorphicContainer(
            opacity: 0.15,
            blur: 20,
            borderColor: widget.widget.category.color.withOpacity(0.5),
            child: Column(
              children: [
                _buildHeader(),
                if (!widget.widget.isMinimized) _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.widget.category.color.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: widget.widget.category.color.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.widget.category.icon,
            size: 20,
            color: widget.widget.category.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Snap to edge toggle
          IconButton(
            icon: Icon(
              widget.widget.snapToEdge ? Icons.push_pin : Icons.push_pin_outlined,
              size: 18,
            ),
            color: widget.widget.snapToEdge
                ? widget.widget.category.color
                : Colors.white.withOpacity(0.5),
            onPressed: () {
              ref
                  .read(floatingWidgetsProvider.notifier)
                  .toggleSnapToEdge(widget.widget.id);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Minimize/Maximize button
          IconButton(
            icon: Icon(
              widget.widget.isMinimized
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
              size: 18,
            ),
            color: Colors.white.withOpacity(0.7),
            onPressed: () {
              ref
                  .read(floatingWidgetsProvider.notifier)
                  .toggleMinimize(widget.widget.id);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.white.withOpacity(0.7),
            onPressed: () {
              ref
                  .read(floatingWidgetsProvider.notifier)
                  .removeWidget(widget.widget.id);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: widget.widget.content,
      ),
    );
  }
}
