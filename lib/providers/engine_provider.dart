import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vib3_parameters.dart';

class EngineState {
  final Map<VIB3Parameters, num> parameters;
  final String activeSystem; // 'faceted', 'quantum', 'holographic', 'polychora'
  final int activeGeometry; // 0-23

  EngineState({
    required this.parameters,
    this.activeSystem = 'faceted',
    this.activeGeometry = 0,
  });

  EngineState copyWith({
    Map<VIB3Parameters, num>? parameters,
    String? activeSystem,
    int? activeGeometry,
  }) {
    return EngineState(
      parameters: parameters ?? this.parameters,
      activeSystem: activeSystem ?? this.activeSystem,
      activeGeometry: activeGeometry ?? this.activeGeometry,
    );
  }
}

class EngineNotifier extends StateNotifier<EngineState> {
  EngineNotifier() : super(EngineState(parameters: _getDefaults()));

  static Map<VIB3Parameters, num> _getDefaults() {
    final defaults = <VIB3Parameters, num>{};
    for (final param in allParameters) {
      defaults[param.key] = param.defaultValue;
    }
    return defaults;
  }

  void setParameter(VIB3Parameters param, num value) {
    final newParams = Map<VIB3Parameters, num>.from(state.parameters);
    newParams[param] = value;
    state = state.copyWith(parameters: newParams);

    // TODO: Send to WebGL via JavaScript bridge
    _sendToWebGL(param, value);
  }

  void applyParameterBatch(Map<VIB3Parameters, num> batch) {
    final newParams = Map<VIB3Parameters, num>.from(state.parameters);
    newParams.addAll(batch);
    state = state.copyWith(parameters: newParams);

    // TODO: Send batch to WebGL
    _sendBatchToWebGL(batch);
  }

  void setActiveSystem(String system) {
    state = state.copyWith(activeSystem: system);
    // TODO: Send to WebGL
  }

  void randomizeAll() {
    final newParams = <VIB3Parameters, num>{};
    for (final param in allParameters) {
      final range = param.range;
      final random = (range[1] - range[0]) * (DateTime.now().millisecondsSinceEpoch % 100) / 100.0;
      newParams[param.key] = range[0] + random;
    }
    state = state.copyWith(parameters: newParams);
  }

  void resetAll() {
    state = EngineState(parameters: _getDefaults());
  }

  void loadPreset(Map<VIB3Parameters, num> presetParams) {
    applyParameterBatch(presetParams);
  }

  void _sendToWebGL(VIB3Parameters param, num value) {
    // TODO: Implement JavaScript bridge communication
    print('WebGL: ${param.name} = $value');
  }

  void _sendBatchToWebGL(Map<VIB3Parameters, num> batch) {
    // TODO: Implement batch update
    print('WebGL Batch: ${batch.length} parameters');
  }
}

final engineProvider = StateNotifierProvider<EngineNotifier, EngineState>((ref) {
  return EngineNotifier();
});
