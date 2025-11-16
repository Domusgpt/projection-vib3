import 'dart:math';
import 'package:flutter/material.dart';

enum PaletteOrbitMode {
  circular,
  pingPong,
  randomWalk,
  beatTriggered,
}

enum PaletteTrigger {
  everyBeat,
  downbeat,
  bassThreshold,
  onsetDetection,
}

enum PaletteSwapType {
  nextInSequence,
  random,
  complementary,
  analogous,
}

class LabColor {
  final double l; // Lightness (0-100)
  final double a; // Green-Red (-128 to 127)
  final double b; // Blue-Yellow (-128 to 127)

  const LabColor(this.l, this.a, this.b);
}

class ColorPalette {
  final String name;
  final List<Color> colors;

  const ColorPalette({
    required this.name,
    required this.colors,
  });

  static const presets = [
    ColorPalette(
      name: 'Sunset Vibes',
      colors: [
        Color(0xFFFF5733),
        Color(0xFFFFC300),
        Color(0xFFFF8C42),
        Color(0xFFFF6B9D),
        Color(0xFFC70039),
        Color(0xFF900C3F),
        Color(0xFF581845),
        Color(0xFF2E1A4A),
      ],
    ),
    ColorPalette(
      name: 'Ocean Depths',
      colors: [
        Color(0xFF001F3F),
        Color(0xFF0074D9),
        Color(0xFF39CCCC),
        Color(0xFF2ECC40),
        Color(0xFF01FF70),
        Color(0xFF7FDBFF),
        Color(0xFF85144B),
        Color(0xFF001529),
      ],
    ),
    ColorPalette(
      name: 'Neon Nights',
      colors: [
        Color(0xFFFF00FF),
        Color(0xFF00FFFF),
        Color(0xFFFF0080),
        Color(0xFF8000FF),
        Color(0xFF00FF00),
        Color(0xFFFFFF00),
        Color(0xFFFF0000),
        Color(0xFF0000FF),
      ],
    ),
    ColorPalette(
      name: 'Forest',
      colors: [
        Color(0xFF2D5016),
        Color(0xFF4A7C2E),
        Color(0xFF6FA843),
        Color(0xFF90C96B),
        Color(0xFF5B8C3B),
        Color(0xFF3E6B29),
        Color(0xFF1F3D0D),
        Color(0xFF0F2205),
      ],
    ),
    ColorPalette(
      name: 'Cyberpunk',
      colors: [
        Color(0xFFFF006E),
        Color(0xFF8338EC),
        Color(0xFF3A86FF),
        Color(0xFFFB5607),
        Color(0xFFFFBE0B),
        Color(0xFF00F5FF),
        Color(0xFFFF0080),
        Color(0xFF9D00FF),
      ],
    ),
    ColorPalette(
      name: 'Pastel Dreams',
      colors: [
        Color(0xFFFFB3BA),
        Color(0xFFFFDFBA),
        Color(0xFFFFFFBA),
        Color(0xFFBAFFD4),
        Color(0xFFBAE1FF),
        Color(0xFFE0BBE4),
        Color(0xFFFEC8D8),
        Color(0xFFD4F1F4),
      ],
    ),
    ColorPalette(
      name: 'Fire & Ice',
      colors: [
        Color(0xFFFF3A00),
        Color(0xFFFF6100),
        Color(0xFFFF8800),
        Color(0xFFFFB000),
        Color(0xFF00BFFF),
        Color(0xFF0080FF),
        Color(0xFF0040FF),
        Color(0xFF0000FF),
      ],
    ),
    ColorPalette(
      name: 'Monochrome',
      colors: [
        Color(0xFF000000),
        Color(0xFF1A1A1A),
        Color(0xFF333333),
        Color(0xFF4D4D4D),
        Color(0xFF666666),
        Color(0xFF999999),
        Color(0xFFCCCCCC),
        Color(0xFFFFFFFF),
      ],
    ),
  ];
}

/// Utilities for Lab color space conversion and blending
class LabColorUtils {
  static LabColor rgbToLab(Color rgb) {
    // RGB → XYZ → Lab conversion
    final r = _gammaCorrect(rgb.red / 255.0);
    final g = _gammaCorrect(rgb.green / 255.0);
    final b = _gammaCorrect(rgb.blue / 255.0);

    final x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    final y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    final z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    final l = 116 * _labF(y / 1.0) - 16;
    final a = 500 * (_labF(x / 0.95047) - _labF(y / 1.0));
    final bValue = 200 * (_labF(y / 1.0) - _labF(z / 1.08883));

    return LabColor(l, a, bValue);
  }

  static Color labToRgb(LabColor lab) {
    // Lab → XYZ → RGB conversion
    final fy = (lab.l + 16) / 116;
    final fx = lab.a / 500 + fy;
    final fz = fy - lab.b / 200;

    final x = 0.95047 * _labFInv(fx);
    final y = 1.0 * _labFInv(fy);
    final z = 1.08883 * _labFInv(fz);

    final r = x * 3.2406 + y * -1.5372 + z * -0.4986;
    final g = x * -0.9689 + y * 1.8758 + z * 0.0415;
    final b = x * 0.0557 + y * -0.2040 + z * 1.0570;

    return Color.fromARGB(
      255,
      (_inverseGammaCorrect(r) * 255).clamp(0, 255).toInt(),
      (_inverseGammaCorrect(g) * 255).clamp(0, 255).toInt(),
      (_inverseGammaCorrect(b) * 255).clamp(0, 255).toInt(),
    );
  }

  static Color labInterpolate(Color c1, Color c2, double t) {
    final lab1 = rgbToLab(c1);
    final lab2 = rgbToLab(c2);

    final labMix = LabColor(
      lab1.l + (lab2.l - lab1.l) * t,
      lab1.a + (lab2.a - lab1.a) * t,
      lab1.b + (lab2.b - lab1.b) * t,
    );

    return labToRgb(labMix);
  }

  static double _gammaCorrect(double c) {
    return c > 0.04045 ? pow((c + 0.055) / 1.055, 2.4).toDouble() : c / 12.92;
  }

  static double _inverseGammaCorrect(double c) {
    return c > 0.0031308 ? 1.055 * pow(c, 1.0 / 2.4) - 0.055 : 12.92 * c;
  }

  static double _labF(double t) {
    return t > 0.008856 ? pow(t, 1.0 / 3.0).toDouble() : 7.787 * t + 16.0 / 116.0;
  }

  static double _labFInv(double t) {
    final t3 = t * t * t;
    return t3 > 0.008856 ? t3 : (t - 16.0 / 116.0) / 7.787;
  }
}
