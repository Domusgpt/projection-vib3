import 'package:flutter/material.dart';
import '../../utils/vib3_colors.dart';

class MultiTouchFeedback extends StatelessWidget {
  final int fingerCount;

  const MultiTouchFeedback({
    super.key,
    required this.fingerCount,
  });

  @override
  Widget build(BuildContext context) {
    if (fingerCount == 0) return SizedBox.shrink();

    Color borderColor;
    String label;

    switch (fingerCount) {
      case 1:
        borderColor = VIB3Colors.purple;
        label = 'XW + YW';
        break;
      case 2:
        borderColor = VIB3Colors.cyan;
        label = 'XY + ZW';
        break;
      case 3:
        borderColor = VIB3Colors.magenta;
        label = 'XZ + YZ';
        break;
      default:
        borderColor = VIB3Colors.pink;
        label = 'All 6 Planes';
        break;
    }

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '👆' * fingerCount.clamp(1, 3),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
