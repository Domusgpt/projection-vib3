import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/macro_provider.dart';
import '../../../providers/audio_provider.dart';

class MacrosTab extends ConsumerWidget {
  const MacrosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroState = ref.watch(macroProvider);
    final audioState = ref.watch(audioProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'MACRO CONTROLS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.macros,
                ),
              ),
              Spacer(),
              Icon(
                audioState.isAudioActive ? Icons.graphic_eq : Icons.graphic_eq_outlined,
                size: 16,
                color: audioState.isAudioActive ? VIB3Colors.green : Colors.white38,
              ),
              SizedBox(width: 4),
              Text(
                audioState.isAudioActive ? 'Audio Active' : 'Audio Off',
                style: TextStyle(
                  fontSize: 10,
                  color: audioState.isAudioActive ? VIB3Colors.green : Colors.white38,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: macroState.macros.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final macro = macroState.macros[index];
                return _buildMacroControl(ref, macro, audioState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroControl(WidgetRef ref, macro, AudioState audioState) {
    final isAudioReactive = macro.audioReactive != null && macro.audioReactive.enabled;
    final audioValue = isAudioReactive
        ? _getAudioSourceValue(audioState, macro.audioReactive.source)
        : 0.0;

    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.macros.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Macro header
          Row(
            children: [
              Icon(Icons.tune, size: 16, color: VIB3CategoryColors.macros),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  macro.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isAudioReactive) ...[
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
                      Icon(Icons.graphic_eq, size: 10, color: VIB3Colors.green),
                      SizedBox(width: 4),
                      Text(
                        _getAudioSourceName(macro.audioReactive.source),
                        style: TextStyle(
                          fontSize: 9,
                          color: VIB3Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
              ],
              _miniButton(Icons.push_pin, () {
                // TODO: Pull out macro control
              }),
            ],
          ),
          SizedBox(height: 12),
          // Master slider
          Row(
            children: [
              Text(
                'Master',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    // Audio reactivity visualization (background)
                    if (isAudioReactive)
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              VIB3Colors.green.withOpacity(0.0),
                              VIB3Colors.green.withOpacity(0.3),
                            ],
                            stops: [0.0, audioValue.clamp(0.0, 1.0)],
                          ),
                        ),
                      ),
                    // Main slider
                    Slider(
                      value: macro.masterValue,
                      min: 0,
                      max: 1,
                      activeColor: VIB3CategoryColors.macros,
                      inactiveColor: VIB3CategoryColors.macros.withOpacity(0.3),
                      onChanged: (value) {
                        ref.read(macroProvider.notifier).setMacroValue(
                              macro.id,
                              value,
                            );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 40,
                alignment: Alignment.centerRight,
                child: Text(
                  '${(macro.masterValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: VIB3CategoryColors.macros,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Affected parameters display
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VIB3CategoryColors.macros.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: VIB3CategoryColors.macros.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Affects ${macro.parameterMappings.length} parameters:',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: macro.parameterMappings.entries.map<Widget>((entry) {
                    final paramName = entry.key;
                    final mapping = entry.value;
                    final calculatedValue = mapping.calculateValue(macro.masterValue);

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            paramName,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            calculatedValue.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 9,
                              color: VIB3CategoryColors.macros,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAudioSourceName(source) {
    final sourceName = source.toString().split('.').last;
    return sourceName
        .replaceAll('Level', '')
        .replaceAll('Trigger', '')
        .replaceAll('Progress', '');
  }

  double _getAudioSourceValue(AudioState audioState, source) {
    // This would normally come from the provider, simplified here
    switch (source.toString()) {
      case 'AudioSource.bassLevel':
        return audioState.analyzer.bassLevel;
      case 'AudioSource.midLevel':
        return audioState.analyzer.midLevel;
      case 'AudioSource.overallVolume':
        return audioState.analyzer.overallVolume;
      case 'AudioSource.beatTrigger':
        return audioState.beatEngine.kickDetected ? 1.0 : 0.0;
      default:
        return 0.0;
    }
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
