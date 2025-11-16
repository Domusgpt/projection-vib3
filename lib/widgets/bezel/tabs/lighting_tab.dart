import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/lighting_provider.dart';
import '../../../models/lighting_system.dart';

class LightingTab extends ConsumerWidget {
  const LightingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightingState = ref.watch(lightingProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '3-POINT LIGHTING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.lighting,
                ),
              ),
              Spacer(),
              // Preset selector dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: VIB3CategoryColors.lighting.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: VIB3CategoryColors.lighting.withOpacity(0.4),
                  ),
                ),
                child: DropdownButton<String>(
                  value: 'Custom',
                  underline: SizedBox(),
                  dropdownColor: VIB3Colors.darkPurple,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                  items: [
                    'Custom',
                    'Studio',
                    'Stage',
                    'Cinematic',
                    'Neon',
                    'Dramatic'
                  ].map((preset) {
                    return DropdownMenuItem(
                      value: preset,
                      child: Text(preset),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && value != 'Custom') {
                      final preset = LightingPreset.getAllPresets()
                          .firstWhere((p) => p.name == value);
                      ref.read(lightingProvider.notifier).loadPreset(preset);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                if (lightingState.keyLight != null)
                  _buildLightControl(
                    ref,
                    'Key Light',
                    lightingState.keyLight!,
                    Icons.wb_sunny,
                    (light) =>
                        ref.read(lightingProvider.notifier).updateKeyLight(light),
                  ),
                SizedBox(height: 10),
                if (lightingState.fillLight != null)
                  _buildLightControl(
                    ref,
                    'Fill Light',
                    lightingState.fillLight!,
                    Icons.wb_cloudy,
                    (light) =>
                        ref.read(lightingProvider.notifier).updateFillLight(light),
                  ),
                SizedBox(height: 10),
                if (lightingState.backLight != null)
                  _buildLightControl(
                    ref,
                    'Back Light',
                    lightingState.backLight!,
                    Icons.wb_twilight,
                    (light) =>
                        ref.read(lightingProvider.notifier).updateBackLight(light),
                  ),
                SizedBox(height: 10),
                if (lightingState.ambientLight != null)
                  _buildLightControl(
                    ref,
                    'Ambient',
                    lightingState.ambientLight!,
                    Icons.nights_stay,
                    (light) =>
                        ref.read(lightingProvider.notifier).updateAmbientLight(light),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightControl(
    WidgetRef ref,
    String name,
    Light light,
    IconData icon,
    Function(Light) onUpdate,
  ) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.lighting.withOpacity(0.4),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: VIB3CategoryColors.lighting),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              if (light.audioReactive)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: VIB3Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: VIB3Colors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.graphic_eq, size: 8, color: VIB3Colors.green),
                      SizedBox(width: 4),
                      Text(
                        light.audioSource ?? 'Audio',
                        style: TextStyle(
                          fontSize: 8,
                          color: VIB3Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Intensity', style: TextStyle(fontSize: 9, color: Colors.white60)),
              SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: light.intensity,
                  min: 0,
                  max: 2,
                  activeColor: VIB3CategoryColors.lighting,
                  inactiveColor: VIB3CategoryColors.lighting.withOpacity(0.3),
                  onChanged: (value) {
                    onUpdate(light.copyWith(intensity: value));
                  },
                ),
              ),
              Text(
                '${(light.intensity * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.lighting,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Color', style: TextStyle(fontSize: 9, color: Colors.white60)),
              SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: light.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '#${light.color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(fontSize: 8, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
