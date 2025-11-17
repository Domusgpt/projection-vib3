import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/engine_provider.dart';
import '../../../models/vib3_parameters.dart';

class EffectsTab extends ConsumerWidget {
  const EffectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISUAL EFFECTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.effects,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildCardBendSection(ref, engineState),
                SizedBox(height: 12),
                _buildPerspectiveSection(ref, engineState),
                SizedBox(height: 12),
                _buildPostProcessingSection(ref, engineState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBendSection(WidgetRef ref, EngineState engineState) {
    final cardBend = engineState.parameters[VIB3Parameters.cardBend]?.toDouble() ?? 0.0;
    final cardBendAxis = engineState.parameters[VIB3Parameters.cardBendAxis]?.toDouble() ?? 0.0;

    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.effects.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, size: 16, color: VIB3CategoryColors.effects),
              SizedBox(width: 8),
              Text(
                'Card Bend Effect',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              _miniButton(Icons.push_pin, () {}),
            ],
          ),
          SizedBox(height: 12),
          // Bend Amount
          Row(
            children: [
              Text('Amount', style: TextStyle(fontSize: 10, color: Colors.white70)),
              SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: cardBend,
                  min: 0,
                  max: 1,
                  activeColor: VIB3CategoryColors.effects,
                  inactiveColor: VIB3CategoryColors.effects.withOpacity(0.3),
                  onChanged: (value) {
                    ref.read(engineProvider.notifier).setParameter(
                          VIB3Parameters.cardBend,
                          value,
                        );
                  },
                ),
              ),
              Text(
                '${(cardBend * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.effects,
                ),
              ),
            ],
          ),
          // Bend Axis
          Row(
            children: [
              Text('Axis', style: TextStyle(fontSize: 10, color: Colors.white70)),
              SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: cardBendAxis,
                  min: 0,
                  max: 6.28,
                  activeColor: VIB3CategoryColors.effects,
                  inactiveColor: VIB3CategoryColors.effects.withOpacity(0.3),
                  onChanged: (value) {
                    ref.read(engineProvider.notifier).setParameter(
                          VIB3Parameters.cardBendAxis,
                          value,
                        );
                  },
                ),
              ),
              Text(
                cardBendAxis.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.effects,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Preset buttons
          Wrap(
            spacing: 6,
            children: [
              _presetButton('X Axis', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.cardBendAxis,
                      0.0,
                    );
              }),
              _presetButton('Y Axis', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.cardBendAxis,
                      1.57,
                    );
              }),
              _presetButton('Diagonal', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.cardBendAxis,
                      0.785,
                    );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerspectiveSection(WidgetRef ref, EngineState engineState) {
    final perspectiveFOV =
        engineState.parameters[VIB3Parameters.perspectiveFOV]?.toDouble() ?? 75.0;

    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.effects.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.aspect_ratio, size: 16, color: VIB3CategoryColors.effects),
              SizedBox(width: 8),
              Text(
                'Perspective Shift',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              _miniButton(Icons.push_pin, () {}),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text('FOV', style: TextStyle(fontSize: 10, color: Colors.white70)),
              SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: perspectiveFOV,
                  min: 30,
                  max: 120,
                  activeColor: VIB3CategoryColors.effects,
                  inactiveColor: VIB3CategoryColors.effects.withOpacity(0.3),
                  onChanged: (value) {
                    ref.read(engineProvider.notifier).setParameter(
                          VIB3Parameters.perspectiveFOV,
                          value,
                        );
                  },
                ),
              ),
              Text(
                '${perspectiveFOV.toInt()}°',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.effects,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              _presetButton('Wide (30°)', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.perspectiveFOV,
                      30.0,
                    );
              }),
              _presetButton('Normal (75°)', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.perspectiveFOV,
                      75.0,
                    );
              }),
              _presetButton('Fisheye (120°)', () {
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.perspectiveFOV,
                      120.0,
                    );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostProcessingSection(WidgetRef ref, EngineState engineState) {
    final bloom = engineState.parameters[VIB3Parameters.bloom]?.toDouble() ?? 0.0;
    final chromaticAberration =
        engineState.parameters[VIB3Parameters.chromaticAberration]?.toDouble() ?? 0.0;
    final rgbShift = engineState.parameters[VIB3Parameters.rgbShift]?.toDouble() ?? 0.0;

    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.effects.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter, size: 16, color: VIB3CategoryColors.effects),
              SizedBox(width: 8),
              Text(
                'Post-Processing',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Bloom
          _buildEffectRow(
            ref,
            'Bloom',
            bloom,
            VIB3Parameters.bloom,
            Icons.wb_sunny,
          ),
          SizedBox(height: 8),
          // Chromatic Aberration
          _buildEffectRow(
            ref,
            'Chromatic Aberration',
            chromaticAberration,
            VIB3Parameters.chromaticAberration,
            Icons.blur_on,
          ),
          SizedBox(height: 8),
          // RGB Shift
          _buildEffectRow(
            ref,
            'RGB Shift',
            rgbShift,
            VIB3Parameters.rgbShift,
            Icons.gradient,
          ),
          SizedBox(height: 12),
          // All off button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(engineProvider.notifier).setParameter(VIB3Parameters.bloom, 0.0);
                ref.read(engineProvider.notifier).setParameter(
                      VIB3Parameters.chromaticAberration,
                      0.0,
                    );
                ref.read(engineProvider.notifier).setParameter(VIB3Parameters.rgbShift, 0.0);
              },
              icon: Icon(Icons.clear_all, size: 14),
              label: Text('Clear All', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: VIB3CategoryColors.effects.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectRow(
    WidgetRef ref,
    String label,
    double value,
    VIB3Parameters param,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 12, color: VIB3CategoryColors.effects.withOpacity(0.7)),
        SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 1,
            activeColor: VIB3CategoryColors.effects,
            inactiveColor: VIB3CategoryColors.effects.withOpacity(0.3),
            onChanged: (newValue) {
              ref.read(engineProvider.notifier).setParameter(param, newValue);
            },
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.effects,
            ),
          ),
        ),
        _miniButton(Icons.push_pin, () {}),
      ],
    );
  }

  Widget _presetButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: VIB3CategoryColors.effects.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9),
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
