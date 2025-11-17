import 'package:flutter/material.dart';
import '../../utils/vib3_colors.dart';
import '../../utils/vib3_theme.dart';

/// Loading widget for audio initialization with animated visualizer
class AudioLoadingWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onCancel;

  const AudioLoadingWidget({
    super.key,
    this.message = 'Initializing Audio...',
    this.onCancel,
  });

  @override
  State<AudioLoadingWidget> createState() => _AudioLoadingWidgetState();
}

class _AudioLoadingWidgetState extends State<AudioLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassmorphicContainer(
        width: 280,
        height: 200,
        opacity: 0.9,
        blur: 12,
        borderColor: VIB3Colors.green.withOpacity(0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated audio visualizer bars
            SizedBox(
              width: 120,
              height: 60,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final height = 20 +
                          40 *
                              (0.5 +
                                  0.5 *
                                      (index % 2 == 0
                                          ? _controller.value
                                          : 1 - _controller.value));
                      return Container(
                        width: 12,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              VIB3Colors.green,
                              VIB3Colors.cyan,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Text(
              widget.message,
              style: TextStyle(
                color: VIB3Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                color: VIB3Colors.green,
                backgroundColor: VIB3Colors.green.withOpacity(0.2),
              ),
            ),
            if (widget.onCancel != null) ...[
              SizedBox(height: 16),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
