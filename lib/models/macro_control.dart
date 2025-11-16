import 'dart:math';
import '../models/audio_band.dart';

class MacroMapping {
  final double scale; // Multiplier
  final double offset; // Base value
  final double power; // Curve (1.0 = linear, 2.0 = quadratic, etc.)

  const MacroMapping({
    this.scale = 1.0,
    this.offset = 0.0,
    this.power = 1.0,
  });

  double calculateValue(double master) {
    return offset + (pow(master, power) * scale);
  }
}

class AudioReactivityConfig {
  final AudioSource source;
  final double intensity;
  final bool enabled;

  const AudioReactivityConfig({
    required this.source,
    this.intensity = 0.5,
    this.enabled = false,
  });
}

class MacroControl {
  final String name;
  final String id;
  final Map<String, MacroMapping> parameterMappings;
  final AudioReactivityConfig? audioReactive;

  double masterValue;

  MacroControl({
    required this.name,
    required this.id,
    required this.parameterMappings,
    this.audioReactive,
    this.masterValue = 0.0,
  });

  Map<String, double> getAffectedParameters() {
    final result = <String, double>{};
    parameterMappings.forEach((param, mapping) {
      result[param] = mapping.calculateValue(masterValue);
    });
    return result;
  }

  void updateMaster(double newValue) {
    masterValue = newValue.clamp(0.0, 1.0);
  }

  void applyAudioReactivity(double audioValue) {
    if (audioReactive != null && audioReactive!.enabled) {
      final reactiveValue = audioValue * audioReactive!.intensity;
      updateMaster((masterValue + reactiveValue).clamp(0.0, 1.0));
    }
  }
}

/// Preset macro configurations
class MacroPresets {
  static MacroControl intensitySweep() {
    return MacroControl(
      name: 'Intensity Sweep',
      id: 'macro1',
      parameterMappings: {
        'intensity': MacroMapping(scale: 1.0, offset: 0.0, power: 1.0),
        'saturation': MacroMapping(scale: 0.8, offset: 0.2, power: 1.0),
        'speed': MacroMapping(scale: 2.0, offset: 0.5, power: 1.5),
        'gridDensity': MacroMapping(scale: 100, offset: 0, power: 1.0),
      },
      audioReactive: AudioReactivityConfig(
        source: AudioSource.overallVolume,
        intensity: 0.4,
        enabled: true,
      ),
    );
  }

  static MacroControl rotationComplexity() {
    return MacroControl(
      name: 'Rotation Complexity',
      id: 'macro2',
      parameterMappings: {
        'rotationXW': MacroMapping(scale: 6.28, offset: 0.0, power: 1.0),
        'rotationYW': MacroMapping(scale: 6.28, offset: 0.0, power: 1.0),
        'rotationZW': MacroMapping(scale: 3.14, offset: 0.0, power: 1.0),
        'morphFactor': MacroMapping(scale: 1.0, offset: 0.0, power: 1.0),
      },
      audioReactive: AudioReactivityConfig(
        source: AudioSource.midLevel,
        intensity: 0.5,
        enabled: true,
      ),
    );
  }

  static MacroControl colorChaos() {
    return MacroControl(
      name: 'Color Chaos',
      id: 'macro3',
      parameterMappings: {
        'saturation': MacroMapping(scale: 1.0, offset: 0.0, power: 1.0),
        'chaos': MacroMapping(scale: 1.0, offset: 0.0, power: 1.0),
        'rgbShift': MacroMapping(scale: 0.5, offset: 0.0, power: 1.0),
      },
      audioReactive: AudioReactivityConfig(
        source: AudioSource.beatTrigger,
        intensity: 0.8,
        enabled: true,
      ),
    );
  }

  static List<MacroControl> getAllPresets() {
    return [
      intensitySweep(),
      rotationComplexity(),
      colorChaos(),
    ];
  }
}
