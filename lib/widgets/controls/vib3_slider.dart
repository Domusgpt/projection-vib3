import 'package:flutter/material.dart';
import '../../utils/vib3_theme.dart';

/// Enhanced slider with haptic feedback and visual polish
class VIB3Slider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;
  final bool enableHaptics;

  const VIB3Slider({
    super.key,
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.color,
    required this.onChanged,
    this.valueFormatter,
    this.enableHaptics = true,
  });

  @override
  State<VIB3Slider> createState() => _VIB3SliderState();
}

class _VIB3SliderState extends State<VIB3Slider> {
  double? _lastHapticValue;
  bool _isInteracting = false;

  void _handleChange(double value) {
    // Trigger haptic feedback every 5% change
    if (widget.enableHaptics) {
      final normalizedValue = ((value - widget.min) / (widget.max - widget.min) * 100).round();
      final lastNormalized = _lastHapticValue != null
          ? ((_lastHapticValue! - widget.min) / (widget.max - widget.min) * 100).round()
          : null;

      if (lastNormalized == null || (normalizedValue - lastNormalized).abs() >= 5) {
        VIB3Haptics.light();
        _lastHapticValue = value;
      }
    }

    widget.onChanged(value);
  }

  String _formatValue(double value) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(value);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(_isInteracting ? 12 : 8),
      decoration: BoxDecoration(
        color: _isInteracting
            ? widget.color.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isInteracting
              ? widget.color.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color: _isInteracting ? widget.color : Colors.white70,
                  fontWeight: _isInteracting ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: _isInteracting ? 12 : 10,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                child: Text(_formatValue(widget.value)),
              ),
            ],
          ),
          SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: _isInteracting ? 6 : 4,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: _isInteracting ? 10 : 8,
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: _isInteracting ? 20 : 16,
              ),
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color.withOpacity(0.2),
              thumbColor: widget.color,
              overlayColor: widget.color.withOpacity(0.2),
            ),
            child: Slider(
              value: widget.value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              onChanged: (value) {
                if (!_isInteracting) {
                  setState(() => _isInteracting = true);
                  if (widget.enableHaptics) VIB3Haptics.medium();
                }
                _handleChange(value);
              },
              onChangeEnd: (value) {
                setState(() => _isInteracting = false);
                if (widget.enableHaptics) VIB3Haptics.light();
              },
            ),
          ),
        ],
      ),
    );
  }
}
