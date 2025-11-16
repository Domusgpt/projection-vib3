import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../utils/floating_widget_helper.dart';
import '../../../providers/engine_provider.dart';
import '../../../models/vib3_parameters.dart';

class RotationTab extends ConsumerWidget {
  const RotationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6 ROTATION PLANES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.rotation,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
              children: [
                _buildRotationControl(
                  ref,
                  'XY',
                  VIB3Parameters.rotationXY,
                  engineState.parameters[VIB3Parameters.rotationXY]?.toDouble() ?? 0.0,
                ),
                _buildRotationControl(
                  ref,
                  'XZ',
                  VIB3Parameters.rotationXZ,
                  engineState.parameters[VIB3Parameters.rotationXZ]?.toDouble() ?? 0.0,
                ),
                _buildRotationControl(
                  ref,
                  'YZ',
                  VIB3Parameters.rotationYZ,
                  engineState.parameters[VIB3Parameters.rotationYZ]?.toDouble() ?? 0.0,
                ),
                _buildRotationControl(
                  ref,
                  'XW',
                  VIB3Parameters.rotationXW,
                  engineState.parameters[VIB3Parameters.rotationXW]?.toDouble() ?? 0.0,
                ),
                _buildRotationControl(
                  ref,
                  'YW',
                  VIB3Parameters.rotationYW,
                  engineState.parameters[VIB3Parameters.rotationYW]?.toDouble() ?? 0.0,
                ),
                _buildRotationControl(
                  ref,
                  'ZW',
                  VIB3Parameters.rotationZW,
                  engineState.parameters[VIB3Parameters.rotationZW]?.toDouble() ?? 0.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationControl(
    WidgetRef ref,
    String label,
    VIB3Parameters param,
    double value,
  ) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.rotation.withOpacity(0.4),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.rotation,
            ),
          ),
          SizedBox(height: 8),
          // Circular rotation indicator
          SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: RotationIndicatorPainter(
                value: value,
                color: VIB3CategoryColors.rotation,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${(value % 6.28).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniButton(
                Icons.push_pin,
                () {
                  // Pull out as floating widget
                  FloatingWidgetHelper.pullOutWidget(
                    ref: ref,
                    id: 'rotation_$label',
                    title: 'Rotation $label',
                    category: VIB3ControlCategory.rotation,
                    content: _buildFloatingRotationContent(ref, label, param),
                    size: const Size(280, 350),
                  );
                },
              ),
              SizedBox(width: 4),
              _miniButton(
                Icons.graphic_eq,
                () {
                  // TODO: Audio link dialog
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingRotationContent(
    WidgetRef ref,
    String label,
    VIB3Parameters param,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final engineState = ref.watch(engineProvider);
        final value = engineState.parameters[param]?.toDouble() ?? 0.0;

        return Column(
          children: [
            // Large rotation indicator
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: RotationIndicatorPainter(
                  value: value,
                  color: VIB3CategoryColors.rotation,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Value display
            Text(
              '${(value % 6.28).toStringAsFixed(3)} rad',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${((value % 6.28) * 180 / pi).toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Slider
            Slider(
              value: value % 6.28,
              min: 0,
              max: 6.28,
              divisions: 100,
              activeColor: VIB3CategoryColors.rotation,
              onChanged: (newValue) {
                ref.read(engineProvider.notifier).setParameter(param, newValue);
              },
            ),

            const SizedBox(height: 10),

            // Preset buttons
            Wrap(
              spacing: 8,
              children: [
                _presetButton(ref, param, '0°', 0.0),
                _presetButton(ref, param, '90°', pi / 2),
                _presetButton(ref, param, '180°', pi),
                _presetButton(ref, param, '270°', 3 * pi / 2),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _presetButton(WidgetRef ref, VIB3Parameters param, String label, double value) {
    return ElevatedButton(
      onPressed: () {
        ref.read(engineProvider.notifier).setParameter(param, value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: VIB3CategoryColors.rotation.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _miniButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 12, color: Colors.white60),
        onPressed: onPressed,
      ),
    );
  }
}

class RotationIndicatorPainter extends CustomPainter {
  final double value;
  final Color color;

  RotationIndicatorPainter({
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Value arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * 3.14159 / 180,
      value,
      false,
      arcPaint,
    );

    // Position indicator dot
    final angle = value - 90 * 3.14159 / 180;
    final dotX = center.dx + radius * cos(angle);
    final dotY = center.dy + radius * sin(angle);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(RotationIndicatorPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
