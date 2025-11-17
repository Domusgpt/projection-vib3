import 'vib3_parameters.dart';

class FrequencyBand {
  final String name;
  final double minFreq;
  final double maxFreq;

  const FrequencyBand(this.name, this.minFreq, this.maxFreq);
}

/// 7-Band Audio Analysis System
class SevenBandAnalyzer {
  static const bands = [
    FrequencyBand('Sub', 20, 60), // Sub-bass
    FrequencyBand('Bass', 60, 250), // Bass
    FrequencyBand('Low Mid', 250, 1000), // Low midrange
    FrequencyBand('Mid', 1000, 4000), // Midrange
    FrequencyBand('High Mid', 4000, 8000), // High midrange
    FrequencyBand('Presence', 8000, 16000), // Presence
    FrequencyBand('Air', 16000, 20000), // Air/brilliance
  ];
}

enum AudioSource {
  subLevel, // 20-60 Hz
  bassLevel, // 60-250 Hz
  lowMidLevel, // 250-1000 Hz
  midLevel, // 1000-4000 Hz
  highMidLevel, // 4000-8000 Hz
  presenceLevel, // 8000-16000 Hz
  airLevel, // 16000-20000 Hz
  overallVolume,
  beatTrigger,
  downbeatTrigger,
  measureProgress,
  bpmLFO,
}

enum AudioMappingMode {
  direct,
  inverted,
  smoothed,
  triggered,
  gated,
}

class AudioParameterMapping {
  final AudioSource source;
  final VIB3Parameters targetParameter;
  final double intensity;
  final AudioMappingMode mode;
  final double attackMs;
  final double releaseMs;
  final bool enabled;

  const AudioParameterMapping({
    required this.source,
    required this.targetParameter,
    this.intensity = 1.0,
    this.mode = AudioMappingMode.direct,
    this.attackMs = 10,
    this.releaseMs = 200,
    this.enabled = true,
  });

  double apply(double audioValue, double previousValue) {
    if (!enabled) return previousValue;

    double mappedValue;

    switch (mode) {
      case AudioMappingMode.direct:
        mappedValue = audioValue * intensity;
        break;

      case AudioMappingMode.inverted:
        mappedValue = (1.0 - audioValue) * intensity;
        break;

      case AudioMappingMode.smoothed:
        // Exponential moving average
        final alpha = 1.0 - (1.0 / (1.0 + 16.67 / releaseMs)); // 60fps
        mappedValue = previousValue + alpha * (audioValue - previousValue);
        break;

      case AudioMappingMode.triggered:
        // Jump to value on trigger, decay back
        if (audioValue > 0.8) {
          mappedValue = intensity;
        } else {
          mappedValue = previousValue * (1.0 - 16.67 / releaseMs);
        }
        break;

      case AudioMappingMode.gated:
        // Only active when audio exceeds threshold
        mappedValue = audioValue > 0.5 ? audioValue * intensity : 0.0;
        break;
    }

    return mappedValue;
  }
}
