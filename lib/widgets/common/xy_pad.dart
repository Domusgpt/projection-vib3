import 'package:flutter/material.dart';
import '../../utils/vib3_colors.dart';

class XYPad extends StatefulWidget {
  final String labelX;
  final String labelY;
  final double valueX;
  final double valueY;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Function(double x, double y) onChanged;
  final Color accentColor;

  const XYPad({
    super.key,
    required this.labelX,
    required this.labelY,
    required this.valueX,
    required this.valueY,
    this.minX = 0.0,
    this.maxX = 1.0,
    this.minY = 0.0,
    this.maxY = 1.0,
    required this.onChanged,
    this.accentColor = VIB3Colors.cyan,
  });

  @override
  State<XYPad> createState() => _XYPadState();
}

class _XYPadState extends State<XYPad> {
  late double _currentX;
  late double _currentY;

  @override
  void initState() {
    super.initState();
    _currentX = widget.valueX;
    _currentY = widget.valueY;
  }

  void _updatePosition(Offset localPosition, Size size) {
    // Normalize to 0-1 range
    final normalizedX = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = 1.0 - (localPosition.dy / size.height).clamp(0.0, 1.0); // Invert Y

    // Map to parameter range
    final mappedX = widget.minX + (normalizedX * (widget.maxX - widget.minX));
    final mappedY = widget.minY + (normalizedY * (widget.maxY - widget.minY));

    setState(() {
      _currentX = mappedX;
      _currentY = mappedY;
    });

    widget.onChanged(mappedX, mappedY);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.labelX}: ${_currentX.toStringAsFixed(2)}',
              style: TextStyle(
                color: widget.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.labelY}: ${_currentY.toStringAsFixed(2)}',
              style: TextStyle(
                color: widget.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // XY Pad
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              final box = context.findRenderObject() as RenderBox;
              _updatePosition(details.localPosition, box.size);
            },
            onPanUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              _updatePosition(details.localPosition, box.size);
            },
            child: Container(
              decoration: BoxDecoration(
                color: VIB3Colors.darkPurple.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: XYPadPainter(
                    normalizedX: (_currentX - widget.minX) / (widget.maxX - widget.minX),
                    normalizedY: (_currentY - widget.minY) / (widget.maxY - widget.minY),
                    accentColor: widget.accentColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class XYPadPainter extends CustomPainter {
  final double normalizedX;
  final double normalizedY;
  final Color accentColor;

  XYPadPainter({
    required this.normalizedX,
    required this.normalizedY,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw grid lines
    paint.color = Colors.white.withOpacity(0.1);
    paint.strokeWidth = 1;

    // Vertical grid lines
    for (int i = 1; i < 4; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw crosshair lines at current position
    final posX = size.width * normalizedX;
    final posY = size.height * (1.0 - normalizedY); // Invert Y for drawing

    paint.color = accentColor.withOpacity(0.3);
    paint.strokeWidth = 1;

    // Vertical crosshair
    canvas.drawLine(
      Offset(posX, 0),
      Offset(posX, size.height),
      paint,
    );

    // Horizontal crosshair
    canvas.drawLine(
      Offset(0, posY),
      Offset(size.width, posY),
      paint,
    );

    // Draw position indicator (circle with glow)
    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(
      Offset(posX, posY),
      20,
      glowPaint,
    );

    final circlePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(posX, posY),
      8,
      circlePaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(posX, posY),
      8,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(XYPadPainter oldDelegate) {
    return oldDelegate.normalizedX != normalizedX ||
        oldDelegate.normalizedY != normalizedY ||
        oldDelegate.accentColor != accentColor;
  }
}
