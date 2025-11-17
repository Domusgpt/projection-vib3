import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/audio_band.dart';
import '../../models/vib3_parameters.dart';
import '../../providers/audio_provider.dart';
import '../../utils/vib3_colors.dart';
import '../../utils/vib3_theme.dart';

/// Full audio mapping editor for creating and managing audio-reactive parameter mappings
class AudioMappingEditor extends ConsumerStatefulWidget {
  const AudioMappingEditor({super.key});

  @override
  ConsumerState<AudioMappingEditor> createState() => _AudioMappingEditorState();
}

class _AudioMappingEditorState extends ConsumerState<AudioMappingEditor> {
  AudioSource _selectedSource = AudioSource.bassLevel;
  VIB3Parameters _selectedParameter = VIB3Parameters.rotationXY;
  AudioMappingMode _selectedMode = AudioMappingMode.direct;
  double _intensity = 1.0;
  double _attackMs = 50.0;
  double _releaseMs = 200.0;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: VIB3Colors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Existing mappings list
            Expanded(
              flex: 3,
              child: _buildMappingsList(audioState),
            ),

            // Divider
            Container(
              height: 1,
              color: VIB3Colors.cyan.withOpacity(0.3),
            ),

            // New mapping editor
            Expanded(
              flex: 4,
              child: _buildNewMappingEditor(audioState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: VIB3Colors.cyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.graphic_eq, color: VIB3Colors.cyan, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Audio Mapping Editor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingsList(AudioState audioState) {
    if (audioState.mappings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No audio mappings yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create one below',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: audioState.mappings.length,
      itemBuilder: (context, index) {
        final mapping = audioState.mappings[index];
        return _buildMappingCard(index, mapping);
      },
    );
  }

  Widget _buildMappingCard(int index, AudioParameterMapping mapping) {
    final sourceValue = ref.read(audioProvider.notifier).getAudioValue(mapping.source);

    return GlassmorphicContainer(
      opacity: 0.15,
      blur: 10,
      borderColor: mapping.enabled
          ? VIB3Colors.cyan.withOpacity(0.5)
          : Colors.white.withOpacity(0.2),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Enable/Disable switch
              Switch(
                value: mapping.enabled,
                activeColor: VIB3Colors.cyan,
                onChanged: (_) {
                  ref.read(audioProvider.notifier).toggleMapping(index);
                },
              ),
              const SizedBox(width: 12),

              // Source and target
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getSourceName(mapping.source)} → ${_getParameterName(mapping.targetParameter)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(mapping.mode.name, VIB3Colors.magenta),
                        const SizedBox(width: 4),
                        _buildBadge(
                          'Int: ${(mapping.intensity * 100).toInt()}%',
                          VIB3Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Live value indicator
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: VIB3Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: VIB3Colors.cyan.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40 * sourceValue,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              VIB3Colors.cyan.withOpacity(0.8),
                              VIB3Colors.cyan.withOpacity(0.3),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Value text
                    Center(
                      child: Text(
                        sourceValue.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red.withOpacity(0.7),
                onPressed: () {
                  ref.read(audioProvider.notifier).removeMapping(index);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewMappingEditor(AudioState audioState) {
    final sourceValue = ref.read(audioProvider.notifier).getAudioValue(_selectedSource);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CREATE NEW MAPPING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3Colors.cyan,
            ),
          ),
          const SizedBox(height: 16),

          // Audio source selector
          _buildSectionLabel('Audio Source'),
          const SizedBox(height: 8),
          _buildSourceSelector(sourceValue),
          const SizedBox(height: 16),

          // Target parameter selector
          _buildSectionLabel('Target Parameter'),
          const SizedBox(height: 8),
          _buildParameterSelector(),
          const SizedBox(height: 16),

          // Mapping mode
          _buildSectionLabel('Mapping Mode'),
          const SizedBox(height: 8),
          _buildModeSelector(),
          const SizedBox(height: 16),

          // Intensity slider
          _buildSectionLabel('Intensity'),
          Slider(
            value: _intensity,
            min: 0.0,
            max: 2.0,
            divisions: 40,
            activeColor: VIB3Colors.cyan,
            label: _intensity.toStringAsFixed(2),
            onChanged: (value) {
              setState(() {
                _intensity = value;
              });
            },
          ),
          const SizedBox(height: 8),

          // Envelope controls
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Attack (ms)'),
                    Slider(
                      value: _attackMs,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: VIB3Colors.purple,
                      label: _attackMs.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _attackMs = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Release (ms)'),
                    Slider(
                      value: _releaseMs,
                      min: 0,
                      max: 1000,
                      divisions: 100,
                      activeColor: VIB3Colors.magenta,
                      label: _releaseMs.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _releaseMs = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Add button
          Center(
            child: ElevatedButton.icon(
              onPressed: _addMapping,
              icon: const Icon(Icons.add),
              label: const Text('Add Mapping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VIB3Colors.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSourceSelector(double currentValue) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AudioSource.values.map((source) {
        final isSelected = source == _selectedSource;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSource = source;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? VIB3Colors.cyan.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? VIB3Colors.cyan : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getSourceName(source),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? VIB3Colors.cyan : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParameterSelector() {
    // Group parameters by category
    final parameters = VIB3Parameters.values;

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: parameters.length,
        itemBuilder: (context, index) {
          final param = parameters[index];
          final isSelected = param == _selectedParameter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedParameter = param;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? VIB3Colors.magenta.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? VIB3Colors.magenta : Colors.white.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  _getParameterName(param),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? VIB3Colors.magenta : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AudioMappingMode.values.map((mode) {
        final isSelected = mode == _selectedMode;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMode = mode;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? VIB3Colors.purple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? VIB3Colors.purple : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              mode.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? VIB3Colors.purple : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _addMapping() {
    final mapping = AudioParameterMapping(
      source: _selectedSource,
      targetParameter: _selectedParameter,
      intensity: _intensity,
      mode: _selectedMode,
      attackMs: _attackMs,
      releaseMs: _releaseMs,
      enabled: true,
    );

    ref.read(audioProvider.notifier).addMapping(mapping);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mapping added: ${_getSourceName(_selectedSource)} → ${_getParameterName(_selectedParameter)}',
        ),
        backgroundColor: VIB3Colors.cyan,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getSourceName(AudioSource source) {
    switch (source) {
      case AudioSource.subLevel:
        return 'Sub';
      case AudioSource.bassLevel:
        return 'Bass';
      case AudioSource.lowMidLevel:
        return 'Low Mid';
      case AudioSource.midLevel:
        return 'Mid';
      case AudioSource.highMidLevel:
        return 'High Mid';
      case AudioSource.presenceLevel:
        return 'Presence';
      case AudioSource.airLevel:
        return 'Air';
      case AudioSource.overallVolume:
        return 'Volume';
      case AudioSource.beatTrigger:
        return 'Beat';
      case AudioSource.downbeatTrigger:
        return 'Downbeat';
      case AudioSource.measureProgress:
        return 'Measure';
      case AudioSource.bpmLFO:
        return 'BPM LFO';
    }
  }

  String _getParameterName(VIB3Parameters param) {
    return param.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }
}
