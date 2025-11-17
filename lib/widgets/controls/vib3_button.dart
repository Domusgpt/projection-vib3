import 'package:flutter/material.dart';
import '../../utils/vib3_theme.dart';

/// Enhanced button with haptic feedback, ripple effects, and animations
class VIB3Button extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;
  final bool enableHaptics;
  final double? width;
  final double? height;

  const VIB3Button({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    required this.onPressed,
    this.isActive = false,
    this.enableHaptics = true,
    this.width,
    this.height,
  });

  @override
  State<VIB3Button> createState() => _VIB3ButtonState();
}

class _VIB3ButtonState extends State<VIB3Button>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.enableHaptics) VIB3Haptics.medium();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height ?? 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isActive
                  ? [widget.color, widget.color.withOpacity(0.7)]
                  : [
                      widget.color.withOpacity(0.3),
                      widget.color.withOpacity(0.1)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? widget.color
                  : widget.color.withOpacity(0.4),
              width: widget.isActive ? 2 : 1,
            ),
            boxShadow: widget.isActive || _isPressed
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.isActive ? Colors.white : Colors.white70,
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isActive ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight:
                        widget.isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini circular button for compact UIs
class VIB3MiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool enableHaptics;

  const VIB3MiniButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (enableHaptics) VIB3Haptics.light();
        onPressed();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}
