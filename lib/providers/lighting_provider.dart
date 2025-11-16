import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lighting_system.dart';
import '../providers/audio_provider.dart';

class LightingState {
  final LightingMode mode;
  final Light? keyLight;
  final Light? fillLight;
  final Light? backLight;
  final Light? ambientLight;

  const LightingState({
    this.mode = LightingMode.threePoint,
    this.keyLight,
    this.fillLight,
    this.backLight,
    this.ambientLight,
  });

  LightingState copyWith({
    LightingMode? mode,
    Light? keyLight,
    Light? fillLight,
    Light? backLight,
    Light? ambientLight,
  }) {
    return LightingState(
      mode: mode ?? this.mode,
      keyLight: keyLight ?? this.keyLight,
      fillLight: fillLight ?? this.fillLight,
      backLight: backLight ?? this.backLight,
      ambientLight: ambientLight ?? this.ambientLight,
    );
  }
}

class LightingNotifier extends StateNotifier<LightingState> {
  final Ref ref;

  LightingNotifier(this.ref)
      : super(LightingState(
          mode: LightingMode.threePoint,
          keyLight: LightingPreset.studio.keyLight,
          fillLight: LightingPreset.studio.fillLight,
          backLight: LightingPreset.studio.backLight,
          ambientLight: LightingPreset.studio.ambientLight,
        ));

  void update() {
    final audioState = ref.read(audioProvider);

    // Update audio-reactive lights
    if (state.keyLight?.audioReactive == true) {
      final audioValue = _getAudioValue(
        audioState,
        state.keyLight!.audioSource,
      );
      final newIntensity = state.keyLight!.intensity *
          (1.0 + audioValue * state.keyLight!.audioIntensity);

      state = state.copyWith(
        keyLight: state.keyLight!.copyWith(intensity: newIntensity),
      );
    }

    if (state.fillLight?.audioReactive == true) {
      final audioValue = _getAudioValue(
        audioState,
        state.fillLight!.audioSource,
      );
      final newIntensity = state.fillLight!.intensity *
          (1.0 + audioValue * state.fillLight!.audioIntensity);

      state = state.copyWith(
        fillLight: state.fillLight!.copyWith(intensity: newIntensity),
      );
    }

    if (state.backLight?.audioReactive == true) {
      final audioValue = _getAudioValue(
        audioState,
        state.backLight!.audioSource,
      );
      final newIntensity = state.backLight!.intensity *
          (1.0 + audioValue * state.backLight!.audioIntensity);

      state = state.copyWith(
        backLight: state.backLight!.copyWith(intensity: newIntensity),
      );
    }
  }

  double _getAudioValue(AudioState audioState, String? source) {
    if (source == null) return 0.0;

    switch (source) {
      case 'subLevel':
        return audioState.analyzer.subLevel;
      case 'bassLevel':
        return audioState.analyzer.bassLevel;
      case 'lowMidLevel':
        return audioState.analyzer.lowMidLevel;
      case 'midLevel':
        return audioState.analyzer.midLevel;
      case 'highMidLevel':
        return audioState.analyzer.highMidLevel;
      case 'presenceLevel':
        return audioState.analyzer.presenceLevel;
      case 'airLevel':
        return audioState.analyzer.airLevel;
      default:
        return 0.0;
    }
  }

  void loadPreset(LightingPreset preset) {
    state = LightingState(
      mode: preset.mode,
      keyLight: preset.keyLight,
      fillLight: preset.fillLight,
      backLight: preset.backLight,
      ambientLight: preset.ambientLight,
    );
  }

  void setMode(LightingMode mode) {
    state = state.copyWith(mode: mode);
  }

  void updateKeyLight(Light light) {
    state = state.copyWith(keyLight: light);
  }

  void updateFillLight(Light light) {
    state = state.copyWith(fillLight: light);
  }

  void updateBackLight(Light light) {
    state = state.copyWith(backLight: light);
  }

  void updateAmbientLight(Light light) {
    state = state.copyWith(ambientLight: light);
  }
}

final lightingProvider =
    StateNotifierProvider<LightingNotifier, LightingState>((ref) {
  return LightingNotifier(ref);
});
