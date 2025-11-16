import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/color_palette.dart';
import '../providers/audio_provider.dart';

class PaletteState {
  final ColorPalette currentPalette;
  final PaletteOrbitMode orbitMode;
  final double orbitSpeed;
  final double orbitPosition;
  final bool bpmSynced;
  final PaletteTrigger? swapTrigger;
  final PaletteSwapType? swapType;
  final bool swapEnabled;
  final int transitionMs;

  const PaletteState({
    required this.currentPalette,
    this.orbitMode = PaletteOrbitMode.circular,
    this.orbitSpeed = 0.3,
    this.orbitPosition = 0.0,
    this.bpmSynced = false,
    this.swapTrigger,
    this.swapType,
    this.swapEnabled = false,
    this.transitionMs = 200,
  });

  PaletteState copyWith({
    ColorPalette? currentPalette,
    PaletteOrbitMode? orbitMode,
    double? orbitSpeed,
    double? orbitPosition,
    bool? bpmSynced,
    PaletteTrigger? swapTrigger,
    PaletteSwapType? swapType,
    bool? swapEnabled,
    int? transitionMs,
  }) {
    return PaletteState(
      currentPalette: currentPalette ?? this.currentPalette,
      orbitMode: orbitMode ?? this.orbitMode,
      orbitSpeed: orbitSpeed ?? this.orbitSpeed,
      orbitPosition: orbitPosition ?? this.orbitPosition,
      bpmSynced: bpmSynced ?? this.bpmSynced,
      swapTrigger: swapTrigger ?? this.swapTrigger,
      swapType: swapType ?? this.swapType,
      swapEnabled: swapEnabled ?? this.swapEnabled,
      transitionMs: transitionMs ?? this.transitionMs,
    );
  }
}

class PaletteNotifier extends StateNotifier<PaletteState> {
  final Ref ref;
  int currentPaletteIndex = 0;

  PaletteNotifier(this.ref)
      : super(PaletteState(
          currentPalette: ColorPalette.presets[0],
        ));

  void update(double deltaTime) {
    final audioState = ref.read(audioProvider);

    if (state.bpmSynced) {
      // Sync to measure progress
      state = state.copyWith(
        orbitPosition: audioState.beatEngine.measureProgress,
      );
    } else {
      // Free-running orbit
      final newPosition = (state.orbitPosition + deltaTime * state.orbitSpeed) % 1.0;
      state = state.copyWith(orbitPosition: newPosition);
    }

    // Check for palette swap triggers
    if (state.swapEnabled && state.swapTrigger != null) {
      bool shouldSwap = false;

      switch (state.swapTrigger!) {
        case PaletteTrigger.everyBeat:
          shouldSwap = audioState.beatEngine.kickDetected;
          break;
        case PaletteTrigger.downbeat:
          shouldSwap = audioState.beatEngine.kickDetected &&
              audioState.beatEngine.beatsSinceDownbeat == 0;
          break;
        case PaletteTrigger.bassThreshold:
          shouldSwap = audioState.analyzer.bassLevel > 0.8;
          break;
        case PaletteTrigger.onsetDetection:
          shouldSwap = audioState.analyzer.onsetDetected;
          break;
      }

      if (shouldSwap) {
        _swapPalette();
      }
    }
  }

  void _swapPalette() {
    switch (state.swapType ?? PaletteSwapType.nextInSequence) {
      case PaletteSwapType.nextInSequence:
        currentPaletteIndex = (currentPaletteIndex + 1) % ColorPalette.presets.length;
        break;
      case PaletteSwapType.random:
        currentPaletteIndex = Random().nextInt(ColorPalette.presets.length);
        break;
      case PaletteSwapType.complementary:
      case PaletteSwapType.analogous:
        // TODO: Implement color theory-based swaps
        currentPaletteIndex = (currentPaletteIndex + 1) % ColorPalette.presets.length;
        break;
    }

    state = state.copyWith(
      currentPalette: ColorPalette.presets[currentPaletteIndex],
    );
  }

  Color getCurrentColor() {
    final palette = state.currentPalette.colors;
    if (palette.isEmpty) return Colors.white;

    switch (state.orbitMode) {
      case PaletteOrbitMode.circular:
        return _circularOrbit(palette);
      case PaletteOrbitMode.pingPong:
        return _pingPongOrbit(palette);
      case PaletteOrbitMode.randomWalk:
        return _randomWalkOrbit(palette);
      case PaletteOrbitMode.beatTriggered:
        return palette[ref.read(audioProvider).beatEngine.currentBeat % palette.length];
    }
  }

  Color _circularOrbit(List<Color> palette) {
    final scaledPos = state.orbitPosition * palette.length;
    final index1 = scaledPos.floor() % palette.length;
    final index2 = (index1 + 1) % palette.length;
    final t = scaledPos - scaledPos.floor();

    return LabColorUtils.labInterpolate(palette[index1], palette[index2], t);
  }

  Color _pingPongOrbit(List<Color> palette) {
    final pos = state.orbitPosition < 0.5
        ? state.orbitPosition * 2
        : (1.0 - state.orbitPosition) * 2;
    final scaledPos = pos * palette.length;
    final index1 = scaledPos.floor() % palette.length;
    final index2 = (index1 + 1) % palette.length;
    final t = scaledPos - scaledPos.floor();

    return LabColorUtils.labInterpolate(palette[index1], palette[index2], t);
  }

  Color _randomWalkOrbit(List<Color> palette) {
    // Use Perlin-like noise for smooth random walk
    final index = (sin(state.orbitPosition * pi * 2) * 0.5 + 0.5) * palette.length;
    return palette[index.floor() % palette.length];
  }

  void setPalette(int index) {
    if (index >= 0 && index < ColorPalette.presets.length) {
      currentPaletteIndex = index;
      state = state.copyWith(currentPalette: ColorPalette.presets[index]);
    }
  }

  void setOrbitMode(PaletteOrbitMode mode) {
    state = state.copyWith(orbitMode: mode);
  }

  void setOrbitSpeed(double speed) {
    state = state.copyWith(orbitSpeed: speed);
  }

  void setBPMSync(bool enabled) {
    state = state.copyWith(bpmSynced: enabled);
  }

  void setSwapConfig({
    PaletteTrigger? trigger,
    PaletteSwapType? type,
    bool? enabled,
    int? transitionMs,
  }) {
    state = state.copyWith(
      swapTrigger: trigger ?? state.swapTrigger,
      swapType: type ?? state.swapType,
      swapEnabled: enabled ?? state.swapEnabled,
      transitionMs: transitionMs ?? state.transitionMs,
    );
  }
}

final paletteProvider = StateNotifierProvider<PaletteNotifier, PaletteState>((ref) {
  return PaletteNotifier(ref);
});
