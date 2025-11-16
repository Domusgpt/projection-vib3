import 'package:flutter/material.dart';
import '../../utils/vib3_colors.dart';

/// WebGL Canvas Widget
/// TODO: Integrate flutter_inappwebview to load vib3-plus-engine
class WebGLCanvas extends StatelessWidget {
  const WebGLCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            VIB3Colors.deepPurple.withOpacity(0.3),
            VIB3Colors.darkNavy.withOpacity(0.8),
            Colors.black,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar,
              size: 80,
              color: VIB3Colors.cyan.withOpacity(0.3),
            ),
            SizedBox(height: 20),
            Text(
              'WebGL Canvas',
              style: TextStyle(
                fontSize: 24,
                color: VIB3Colors.cyan.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '4D Visualization Engine',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: VIB3Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: VIB3Colors.cyan.withOpacity(0.3),
                ),
              ),
              child: Text(
                'TODO: Integrate flutter_inappwebview',
                style: TextStyle(
                  fontSize: 12,
                  color: VIB3Colors.cyan.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
