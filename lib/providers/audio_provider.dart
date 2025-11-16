import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_analyzer.dart';
import '../services/beat_detector.dart';
import '../services/audio_input_service.dart';
import '../models/audio_band.dart';

class AudioState {
  final SevenBandAudioAnalyzer analyzer;
  final AudioBeatEngine beatEngine;
  final AudioInputService inputService;
  final List<AudioParameterMapping> mappings;
  final bool isAudioActive;

  const AudioState({
    required this.analyzer,
    required this.beatEngine,
    required this.inputService,
    required this.mappings,
    this.isAudioActive = false,
  });

  AudioState copyWith({
    SevenBandAudioAnalyzer? analyzer,
    AudioBeatEngine? beatEngine,
    AudioInputService? inputService,
    List<AudioParameterMapping>? mappings,
    bool? isAudioActive,
  }) {
    return AudioState(
      analyzer: analyzer ?? this.analyzer,
      beatEngine: beatEngine ?? this.beatEngine,
      inputService: inputService ?? this.inputService,
      mappings: mappings ?? this.mappings,
      isAudioActive: isAudioActive ?? this.isAudioActive,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  Timer? _updateTimer;

  AudioNotifier()
      : super(AudioState(
          analyzer: SevenBandAudioAnalyzer(),
          beatEngine: AudioBeatEngine(),
          inputService: AudioInputService(),
          mappings: [],
        )) {
    _setupAudioInput();
    _startUpdateLoop();
  }

  void _setupAudioInput() {
    // Set up FFT data callback
    state.inputService.onFFTData = (Float32List fftMagnitudes) {
      // Feed FFT data to analyzer
      state.analyzer.analyze(fftMagnitudes, state.inputService.sampleRate);
    };
  }

  void _startUpdateLoop() {
    // 60 FPS update rate
    _updateTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      if (state.isAudioActive) {
        _update();
      }
    });
  }

  void _update() {
    // Update beat engine
    state.beatEngine.update(
      0.016,
      bassLevel: state.analyzer.bassLevel,
      beatTriggered: state.analyzer.onsetDetected,
    );

    // Apply audio mappings would happen here
    // This would be called by the engine provider to get reactive values
  }

  void addMapping(AudioParameterMapping mapping) {
    final newMappings = List<AudioParameterMapping>.from(state.mappings);
    newMappings.add(mapping);
    state = state.copyWith(mappings: newMappings);
  }

  void removeMapping(int index) {
    if (index >= 0 && index < state.mappings.length) {
      final newMappings = List<AudioParameterMapping>.from(state.mappings);
      newMappings.removeAt(index);
      state = state.copyWith(mappings: newMappings);
    }
  }

  void toggleMapping(int index) {
    if (index >= 0 && index < state.mappings.length) {
      final newMappings = List<AudioParameterMapping>.from(state.mappings);
      final mapping = newMappings[index];
      newMappings[index] = AudioParameterMapping(
        source: mapping.source,
        targetParameter: mapping.targetParameter,
        intensity: mapping.intensity,
        mode: mapping.mode,
        attackMs: mapping.attackMs,
        releaseMs: mapping.releaseMs,
        enabled: !mapping.enabled,
      );
      state = state.copyWith(mappings: newMappings);
    }
  }

  void setBPM(double bpm) {
    state.beatEngine.setBPM(bpm);
  }

  void setTimeSignature(TimeSignature sig) {
    state.beatEngine.setTimeSignature(sig);
  }

  void tapTempo() {
    state.beatEngine.tap();
  }

  Future<void> toggleAudioActive() async {
    final newState = !state.isAudioActive;

    if (newState) {
      // Start audio input
      final success = await state.inputService.startListening();
      if (success) {
        state = state.copyWith(isAudioActive: true);
      }
    } else {
      // Stop audio input
      await state.inputService.stopListening();
      state.analyzer.reset();
      state = state.copyWith(isAudioActive: false);
    }
  }

  double getAudioValue(AudioSource source) {
    switch (source) {
      case AudioSource.beatTrigger:
        return state.beatEngine.kickDetected ? 1.0 : 0.0;
      case AudioSource.downbeatTrigger:
        return (state.beatEngine.beatsSinceDownbeat == 0 &&
                state.beatEngine.kickDetected)
            ? 1.0
            : 0.0;
      case AudioSource.measureProgress:
        return state.beatEngine.measureProgress;
      case AudioSource.bpmLFO:
        return state.beatEngine.getLFOSine();
      default:
        return state.analyzer.getBandLevel(source);
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    state.inputService.dispose();
    super.dispose();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
