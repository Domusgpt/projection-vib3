import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/engine_provider.dart';
import '../../../models/vib3_parameters.dart';

class VisualTab extends ConsumerWidget {
  const VisualTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISUAL PARAMETERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.visual,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildParameter(
                  ref,
                  'Grid Density',
                  VIB3Parameters.gridDensity,
                  engineState.parameters[VIB3Parameters.gridDensity]?.toDouble() ?? 20.0,
                  1,
                  100,
                  Icons.grid_on,
                ),
                _buildParameter(
                  ref,
                  'Morph Factor',
                  VIB3Parameters.morphFactor,
                  engineState.parameters[VIB3Parameters.morphFactor]?.toDouble() ?? 0.0,
                  0,
                  1,
                  Icons.transform,
                ),
                _buildParameter(
                  ref,
                  'Chaos',
                  VIB3Parameters.chaos,
                  engineState.parameters[VIB3Parameters.chaos]?.toDouble() ?? 0.0,
                  0,
                  1,
                  Icons.scatter_plot,
                ),
                _buildParameter(
                  ref,
                  'Speed',
                  VIB3Parameters.speed,
                  engineState.parameters[VIB3Parameters.speed]?.toDouble() ?? 1.0,
                  0,
                  10,
                  Icons.speed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameter(
    WidgetRef ref,
    String label,
    VIB3Parameters param,
    double value,
    double min,
    double max,
    IconData icon,
  ) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.visual.withOpacity(0.4),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: VIB3CategoryColors.visual),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _miniButton(Icons.push_pin, () {}),
            ],
          ),
          SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: VIB3CategoryColors.visual,
            inactiveColor: VIB3CategoryColors.visual.withOpacity(0.3),
            onChanged: (newValue) {
              ref.read(engineProvider.notifier).setParameter(param, newValue);
            },
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 12,
              color: VIB3CategoryColors.visual,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
