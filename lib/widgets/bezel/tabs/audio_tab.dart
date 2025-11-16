import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/vib3_colors.dart';
import '../../../utils/vib3_theme.dart';
import '../../../providers/audio_provider.dart';
import '../../../models/audio_band.dart';

class AudioTab extends ConsumerWidget {
  const AudioTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO REACTIVITY CONTROL CENTER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: VIB3CategoryColors.audio,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _build7BandVisualizer(audioState),
                SizedBox(height: 12),
                _buildBPMSection(audioState),
                SizedBox(height: 12),
                _buildAudioMappingsPreview(audioState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build7BandVisualizer(AudioState audioState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.audio.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-BAND FFT ANALYZER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBandBar('Sub', audioState.analyzer.subLevel),
              _buildBandBar('Bass', audioState.analyzer.bassLevel),
              _buildBandBar('Low', audioState.analyzer.lowMidLevel),
              _buildBandBar('Mid', audioState.analyzer.midLevel),
              _buildBandBar('High', audioState.analyzer.highMidLevel),
              _buildBandBar('Pres', audioState.analyzer.presenceLevel),
              _buildBandBar('Air', audioState.analyzer.airLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBandBar(String label, double level) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 30,
              height: level * 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    VIB3CategoryColors.audio,
                    VIB3CategoryColors.audio.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 8, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildBPMSection(AudioState audioState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.audio.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, size: 16, color: VIB3CategoryColors.audio),
              SizedBox(width: 8),
              Text(
                'BPM DETECTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text('BPM:', style: TextStyle(fontSize: 10, color: Colors.white60)),
              SizedBox(width: 8),
              Text(
                '${audioState.beatEngine.bpm.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VIB3CategoryColors.audio,
                ),
              ),
              Spacer(),
              Text(
                'Confidence: ${(audioState.beatEngine.getBPMConfidence() * 100).toInt()}%',
                style: TextStyle(fontSize: 9, color: Colors.white54),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Measure: ${audioState.beatEngine.currentMeasure}  Beat: ${audioState.beatEngine.currentBeat}',
                style: TextStyle(fontSize: 9, color: Colors.white60),
              ),
              Spacer(),
              if (audioState.beatEngine.kickDetected)
                Icon(Icons.circle, size: 12, color: VIB3CategoryColors.audio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMappingsPreview(AudioState audioState) {
    return GlassmorphicContainer(
      opacity: 0.5,
      blur: 6,
      borderColor: VIB3CategoryColors.audio.withOpacity(0.4),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AUDIO MAPPINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              Spacer(),
              Text(
                '${audioState.mappings.length} active',
                style: TextStyle(fontSize: 9, color: VIB3CategoryColors.audio),
              ),
            ],
          ),
          SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.link,
                  size: 40,
                  color: VIB3CategoryColors.audio.withOpacity(0.3),
                ),
                SizedBox(height: 8),
                Text(
                  'Audio→Parameter Mapping Editor',
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),
                SizedBox(height: 4),
                Text(
                  '(Full implementation coming soon)',
                  style: TextStyle(fontSize: 8, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
