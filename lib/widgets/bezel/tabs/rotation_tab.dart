import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/vib3_parameters.dart';
import '../../../providers/engine_provider.dart';
import '../../../utils/vib3_colors.dart';
import '../../common/xy_pad.dart';

class RotationTab extends ConsumerWidget {
  const RotationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);
    final engineNotifier = ref.read(engineProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          '4D ROTATION CONTROL',
          style: TextStyle(
            color: VIB3Colors.cyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Control all 6 rotation planes in 4D space',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        // Three XY pads for the 6 rotation planes
        Expanded(
          child: Row(
            children: [
              // XY Pad 1: XY and XZ rotations
              Expanded(
                child: XYPad(
                  labelX: 'XY Rotation',
                  labelY: 'XZ Rotation',
                  valueX: engineState.parameters[VIB3Parameters.rotationXY] as double,
                  valueY: engineState.parameters[VIB3Parameters.rotationXZ] as double,
                  minX: 0.0,
                  maxX: 6.28,
                  minY: 0.0,
                  maxY: 6.28,
                  accentColor: VIB3Colors.cyan,
                  onChanged: (x, y) {
                    engineNotifier.applyParameterBatch({
                      VIB3Parameters.rotationXY: x,
                      VIB3Parameters.rotationXZ: y,
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // XY Pad 2: YZ and XW rotations
              Expanded(
                child: XYPad(
                  labelX: 'YZ Rotation',
                  labelY: 'XW Rotation',
                  valueX: engineState.parameters[VIB3Parameters.rotationYZ] as double,
                  valueY: engineState.parameters[VIB3Parameters.rotationXW] as double,
                  minX: 0.0,
                  maxX: 6.28,
                  minY: 0.0,
                  maxY: 6.28,
                  accentColor: VIB3Colors.magenta,
                  onChanged: (x, y) {
                    engineNotifier.applyParameterBatch({
                      VIB3Parameters.rotationYZ: x,
                      VIB3Parameters.rotationXW: y,
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // XY Pad 3: YW and ZW rotations
              Expanded(
                child: XYPad(
                  labelX: 'YW Rotation',
                  labelY: 'ZW Rotation',
                  valueX: engineState.parameters[VIB3Parameters.rotationYW] as double,
                  valueY: engineState.parameters[VIB3Parameters.rotationZW] as double,
                  minX: 0.0,
                  maxX: 6.28,
                  minY: 0.0,
                  maxY: 6.28,
                  accentColor: VIB3Colors.purple,
                  onChanged: (x, y) {
                    engineNotifier.applyParameterBatch({
                      VIB3Parameters.rotationYW: x,
                      VIB3Parameters.rotationZW: y,
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
