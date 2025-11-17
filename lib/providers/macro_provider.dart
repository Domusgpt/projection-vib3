import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/macro_control.dart';
import '../models/audio_band.dart';
import '../providers/audio_provider.dart';

class MacroState {
  final List<MacroControl> macros;

  const MacroState({
    required this.macros,
  });

  MacroState copyWith({
    List<MacroControl>? macros,
  }) {
    return MacroState(
      macros: macros ?? this.macros,
    );
  }
}

class MacroNotifier extends StateNotifier<MacroState> {
  final Ref ref;

  MacroNotifier(this.ref)
      : super(MacroState(
          macros: MacroPresets.getAllPresets(),
        ));

  void update() {
    final audioState = ref.read(audioProvider);
    final newMacros = <MacroControl>[];

    for (final macro in state.macros) {
      final updatedMacro = MacroControl(
        name: macro.name,
        id: macro.id,
        parameterMappings: macro.parameterMappings,
        audioReactive: macro.audioReactive,
        masterValue: macro.masterValue,
      );

      // Apply audio reactivity
      if (macro.audioReactive != null && macro.audioReactive!.enabled) {
        final audioValue = _getAudioValue(audioState, macro.audioReactive!.source);
        updatedMacro.applyAudioReactivity(audioValue);
      }

      newMacros.add(updatedMacro);
    }

    state = state.copyWith(macros: newMacros);
  }

  double _getAudioValue(AudioState audioState, AudioSource source) {
    switch (source) {
      case AudioSource.subLevel:
        return audioState.analyzer.subLevel;
      case AudioSource.bassLevel:
        return audioState.analyzer.bassLevel;
      case AudioSource.lowMidLevel:
        return audioState.analyzer.lowMidLevel;
      case AudioSource.midLevel:
        return audioState.analyzer.midLevel;
      case AudioSource.highMidLevel:
        return audioState.analyzer.highMidLevel;
      case AudioSource.presenceLevel:
        return audioState.analyzer.presenceLevel;
      case AudioSource.airLevel:
        return audioState.analyzer.airLevel;
      case AudioSource.overallVolume:
        return audioState.analyzer.overallVolume;
      case AudioSource.beatTrigger:
        return audioState.beatEngine.kickDetected ? 1.0 : 0.0;
      case AudioSource.downbeatTrigger:
        return (audioState.beatEngine.beatsSinceDownbeat == 0 &&
                audioState.beatEngine.kickDetected)
            ? 1.0
            : 0.0;
      case AudioSource.measureProgress:
        return audioState.beatEngine.measureProgress;
      case AudioSource.bpmLFO:
        return audioState.beatEngine.getLFOSine();
    }
  }

  void setMacroValue(String macroId, double value) {
    final newMacros = state.macros.map((macro) {
      if (macro.id == macroId) {
        final updated = MacroControl(
          name: macro.name,
          id: macro.id,
          parameterMappings: macro.parameterMappings,
          audioReactive: macro.audioReactive,
          masterValue: value,
        );
        return updated;
      }
      return macro;
    }).toList();

    state = state.copyWith(macros: newMacros);
  }

  void addMacro(MacroControl macro) {
    final newMacros = List<MacroControl>.from(state.macros);
    newMacros.add(macro);
    state = state.copyWith(macros: newMacros);
  }

  void removeMacro(String macroId) {
    final newMacros = state.macros.where((m) => m.id != macroId).toList();
    state = state.copyWith(macros: newMacros);
  }

  MacroControl? getMacro(String macroId) {
    try {
      return state.macros.firstWhere((m) => m.id == macroId);
    } catch (e) {
      return null;
    }
  }

  Map<String, double> getAllAffectedParameters() {
    final result = <String, double>{};

    for (final macro in state.macros) {
      final affected = macro.getAffectedParameters();
      result.addAll(affected);
    }

    return result;
  }
}

final macroProvider = StateNotifierProvider<MacroNotifier, MacroState>((ref) {
  return MacroNotifier(ref);
});
