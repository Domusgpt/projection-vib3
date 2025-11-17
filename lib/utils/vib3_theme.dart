import 'dart:ui';
import 'package:flutter/material.dart';
import 'vib3_colors.dart';

class VIB3Theme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: VIB3Colors.darkNavy,
      primaryColor: VIB3Colors.cyan,
      colorScheme: ColorScheme.dark(
        primary: VIB3Colors.cyan,
        secondary: VIB3Colors.magenta,
        surface: VIB3Colors.darkNavy,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double opacity;
  final double blur;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.opacity = 0.7,
    this.blur = 10.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VIB3Colors.glassFill.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? VIB3Colors.glassBorder,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class VIB3CategoryColors {
  static const rotation = VIB3Colors.cyan;
  static const visual = VIB3Colors.magenta;
  static const color = VIB3Colors.purple;
  static const audio = VIB3Colors.green;
  static const effects = VIB3Colors.orange;
  static const timeline = VIB3Colors.blue;
  static const camera = VIB3Colors.pink;
  static const lighting = Color(0xFFFFD700); // Gold
  static const macros = Color(0xFF00CED1); // Dark turquoise
}

enum VIB3ControlCategory {
  rotation,
  visual,
  color,
  audio,
  effects,
  timeline,
  camera,
  lighting,
  macros,
}

extension VIB3ControlCategoryExtension on VIB3ControlCategory {
  Color get color {
    switch (this) {
      case VIB3ControlCategory.rotation:
        return VIB3CategoryColors.rotation;
      case VIB3ControlCategory.visual:
        return VIB3CategoryColors.visual;
      case VIB3ControlCategory.color:
        return VIB3CategoryColors.color;
      case VIB3ControlCategory.audio:
        return VIB3CategoryColors.audio;
      case VIB3ControlCategory.effects:
        return VIB3CategoryColors.effects;
      case VIB3ControlCategory.timeline:
        return VIB3CategoryColors.timeline;
      case VIB3ControlCategory.camera:
        return VIB3CategoryColors.camera;
      case VIB3ControlCategory.lighting:
        return VIB3CategoryColors.lighting;
      case VIB3ControlCategory.macros:
        return VIB3CategoryColors.macros;
    }
  }

  String get displayName {
    switch (this) {
      case VIB3ControlCategory.rotation:
        return '4D Rotate';
      case VIB3ControlCategory.visual:
        return 'Visual';
      case VIB3ControlCategory.color:
        return 'Color';
      case VIB3ControlCategory.audio:
        return 'Audio ♪';
      case VIB3ControlCategory.effects:
        return 'Effects';
      case VIB3ControlCategory.timeline:
        return 'Timeline';
      case VIB3ControlCategory.camera:
        return 'Camera 📹';
      case VIB3ControlCategory.lighting:
        return 'Lighting 💡';
      case VIB3ControlCategory.macros:
        return 'Macros 🎛️';
    }
  }

  IconData get icon {
    switch (this) {
      case VIB3ControlCategory.rotation:
        return Icons.threesixty;
      case VIB3ControlCategory.visual:
        return Icons.view_in_ar;
      case VIB3ControlCategory.color:
        return Icons.palette;
      case VIB3ControlCategory.audio:
        return Icons.graphic_eq;
      case VIB3ControlCategory.effects:
        return Icons.auto_fix_high;
      case VIB3ControlCategory.timeline:
        return Icons.timeline;
      case VIB3ControlCategory.camera:
        return Icons.videocam;
      case VIB3ControlCategory.lighting:
        return Icons.lightbulb;
      case VIB3ControlCategory.macros:
        return Icons.tune;
    }
  }
}

class VIB3Haptics {
  static void light() {
    // TODO: Implement haptic feedback
    // HapticFeedback.lightImpact();
  }

  static void medium() {
    // TODO: Implement haptic feedback
    // HapticFeedback.mediumImpact();
  }

  static void heavy() {
    // TODO: Implement haptic feedback
    // HapticFeedback.heavyImpact();
  }

  static void selection() {
    // TODO: Implement haptic feedback
    // HapticFeedback.selectionClick();
  }
}
