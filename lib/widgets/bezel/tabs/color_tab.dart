import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/engine_provider.dart';
import '../../../providers/palette_provider.dart';
import '../../../models/vib3_parameters.dart';
import '../../../models/color_palette.dart';

class ColorTab extends ConsumerWidget {
  const ColorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);
    final paletteState = ref.watch(paletteProvider);

    final hue = engineState.parameters[VIB3Parameters.hue]?.toDouble() ?? 180.0;
    final saturation = engineState.parameters[VIB3Parameters.saturation]?.toDouble() ?? 0.8;
    final intensity = engineState.parameters[VIB3Parameters.intensity]?.toDouble() ?? 1.0;

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COLOR CONTROLS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.color,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                // Left side: Color wheel
                Expanded(
                  flex: 2,
                  child: _buildColorWheel(ref, hue, saturation, intensity),
                ),
                SizedBox(width: 12),
                // Right side: Controls
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildColorPreview(hue, saturation, intensity),
                      SizedBox(height: 12),
                      _buildHueControl(ref, hue),
                      SizedBox(height: 8),
                      _buildSaturationControl(ref, saturation),
                      SizedBox(height: 8),
                      _buildIntensityControl(ref, intensity),
                      SizedBox(height: 12),
                      _buildPalettePresets(ref, paletteState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorWheel(WidgetRef ref, double hue, double saturation, double intensity) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.color.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // TODO: Calculate hue/saturation from touch position
                  // final RenderBox box = context.findRenderObject() as RenderBox;
                  // final Offset localPosition = details.localPosition;
                },
                child: CustomPaint(
                  painter: ColorWheelPainter(
                    hue: hue,
                    saturation: saturation,
                    intensity: intensity,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniButton(Icons.push_pin, () {
                // TODO: Pull out color wheel
              }),
              SizedBox(width: 8),
              _miniButton(Icons.graphic_eq, () {
                // TODO: Audio link
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreview(double hue, double saturation, double intensity) {
    final color = HSVColor.fromAHSV(1.0, hue, saturation, intensity).toColor();

    return GlassmorphicContainer(
      height: 60,
      opacity: 0.5,
      blur: 6,
      borderColor: color.withOpacity(0.8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Color',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                SizedBox(height: 2),
                Text(
                  'H:${hue.toInt()}° S:${(saturation * 100).toInt()}% I:${(intensity * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: VIB3CategoryColors.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHueControl(WidgetRef ref, double hue) {
    return GlassmorphicContainer(
      height: 50,
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.color.withOpacity(0.4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.palette, size: 16, color: VIB3CategoryColors.color),
          SizedBox(width: 6),
          Text('Hue', style: TextStyle(fontSize: 11, color: Colors.white)),
          SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: hue,
              min: 0,
              max: 360,
              activeColor: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
              inactiveColor: Colors.white24,
              onChanged: (value) {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.hue,
                      value,
                    );
              },
            ),
          ),
          Text(
            '${hue.toInt()}°',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.color,
            ),
          ),
          SizedBox(width: 4),
          _miniButton(Icons.push_pin, () {}),
        ],
      ),
    );
  }

  Widget _buildSaturationControl(WidgetRef ref, double saturation) {
    return GlassmorphicContainer(
      height: 50,
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.color.withOpacity(0.4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.opacity, size: 16, color: VIB3CategoryColors.color),
          SizedBox(width: 6),
          Text('Saturation', style: TextStyle(fontSize: 11, color: Colors.white)),
          SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: saturation,
              min: 0,
              max: 1,
              activeColor: VIB3CategoryColors.color,
              inactiveColor: VIB3CategoryColors.color.withOpacity(0.3),
              onChanged: (value) {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.saturation,
                      value,
                    );
              },
            ),
          ),
          Text(
            '${(saturation * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.color,
            ),
          ),
          SizedBox(width: 4),
          _miniButton(Icons.push_pin, () {}),
        ],
      ),
    );
  }

  Widget _buildIntensityControl(WidgetRef ref, double intensity) {
    return GlassmorphicContainer(
      height: 50,
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.color.withOpacity(0.4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.brightness_high, size: 16, color: VIB3CategoryColors.color),
          SizedBox(width: 6),
          Text('Intensity', style: TextStyle(fontSize: 11, color: Colors.white)),
          SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: intensity,
              min: 0,
              max: 1,
              activeColor: VIB3CategoryColors.color,
              inactiveColor: VIB3CategoryColors.color.withOpacity(0.3),
              onChanged: (value) {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.intensity,
                      value,
                    );
              },
            ),
          ),
          Text(
            '${(intensity * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.color,
            ),
          ),
          SizedBox(width: 4),
          _miniButton(Icons.push_pin, () {}),
        ],
      ),
    );
  }

  Widget _buildPalettePresets(WidgetRef ref, PaletteState paletteState) {
    return Expanded(
      child: GlassmorphicContainer(
        opacity: 0.5,
        blur: 6,
        borderColor: VIB3CategoryColors.color.withOpacity(0.4),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Palette Presets',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 2.0,
                ),
                itemCount: ColorPalette.presets.length,
                itemBuilder: (context, index) {
                  final palette = ColorPalette.presets[index];
                  final isActive = paletteState.currentPalette.name == palette.name;

                  return GestureDetector(
                    onTap: () {
                      ref.read(paletteProvider.notifier).setPalette(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: palette.colors.take(3).toList(),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isActive
                              ? VIB3CategoryColors.color
                              : Colors.white24,
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: VIB3CategoryColors.color.withOpacity(0.4),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

class ColorWheelPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double intensity;

  ColorWheelPainter({
    required this.hue,
    required this.saturation,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // Draw color wheel (simplified - just show current hue ring)
    final wheelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    for (int i = 0; i < 360; i++) {
      wheelPaint.color = HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, 1.0).toColor();
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        (i - 90) * pi / 180,
        pi / 180,
        false,
        wheelPaint,
      );
    }

    // Draw current color indicator
    final angle = (hue - 90) * pi / 180;
    final indicatorX = center.dx + (radius - 10) * cos(angle);
    final indicatorY = center.dy + (radius - 10) * sin(angle);

    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(indicatorX, indicatorY), 6, indicatorPaint);

    // Draw inner circle with current color
    final innerColor = HSVColor.fromAHSV(1.0, hue, saturation, intensity).toColor();
    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 35, innerPaint);

    // Draw saturation indicator (white ring)
    final satRingPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, (radius - 35) * saturation, satRingPaint);
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.intensity != intensity;
  }
}
