import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;

enum LightingMode {
  ambient,
  onePoint,
  threePoint,
  custom,
}

class Light {
  final String id;
  final vm.Vector3 position;
  final Color color;
  final double intensity;
  final bool audioReactive;
  final String? audioSource;
  final double audioIntensity;

  const Light({
    required this.id,
    required this.position,
    required this.color,
    required this.intensity,
    this.audioReactive = false,
    this.audioSource,
    this.audioIntensity = 0.5,
  });

  Light copyWith({
    String? id,
    vm.Vector3? position,
    Color? color,
    double? intensity,
    bool? audioReactive,
    String? audioSource,
    double? audioIntensity,
  }) {
    return Light(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      intensity: intensity ?? this.intensity,
      audioReactive: audioReactive ?? this.audioReactive,
      audioSource: audioSource ?? this.audioSource,
      audioIntensity: audioIntensity ?? this.audioIntensity,
    );
  }
}

class LightingPreset {
  final String name;
  final LightingMode mode;
  final Light? keyLight;
  final Light? fillLight;
  final Light? backLight;
  final Light? ambientLight;

  const LightingPreset({
    required this.name,
    required this.mode,
    this.keyLight,
    this.fillLight,
    this.backLight,
    this.ambientLight,
  });

  static final studio = LightingPreset(
    name: 'Studio',
    mode: LightingMode.threePoint,
    keyLight: Light(
      id: 'key',
      position: vm.Vector3(2.0, 3.0, 5.0),
      color: Colors.white,
      intensity: 0.7,
    ),
    fillLight: Light(
      id: 'fill',
      position: vm.Vector3(-2.0, 1.0, 3.0),
      color: Color(0xFFCCDDFF),
      intensity: 0.4,
    ),
    backLight: Light(
      id: 'back',
      position: vm.Vector3(0.0, -2.0, -4.0),
      color: Color(0xFFFFDDCC),
      intensity: 0.5,
    ),
    ambientLight: Light(
      id: 'ambient',
      position: vm.Vector3.zero(),
      color: Color(0xFF333355),
      intensity: 0.2,
    ),
  );

  static final stage = LightingPreset(
    name: 'Stage',
    mode: LightingMode.threePoint,
    keyLight: Light(
      id: 'key',
      position: vm.Vector3(0.0, 5.0, 5.0),
      color: Colors.white,
      intensity: 1.0,
      audioReactive: true,
      audioSource: 'midLevel',
      audioIntensity: 0.6,
    ),
    fillLight: Light(
      id: 'fill',
      position: vm.Vector3(-3.0, 1.0, 2.0),
      color: Color(0xFFFF8844),
      intensity: 0.5,
    ),
    backLight: Light(
      id: 'back',
      position: vm.Vector3(0.0, -3.0, -5.0),
      color: Color(0xFF4488FF),
      intensity: 0.7,
      audioReactive: true,
      audioSource: 'highMidLevel',
      audioIntensity: 0.8,
    ),
    ambientLight: Light(
      id: 'ambient',
      position: vm.Vector3.zero(),
      color: Color(0xFF221133),
      intensity: 0.1,
    ),
  );

  static final cinematic = LightingPreset(
    name: 'Cinematic',
    mode: LightingMode.threePoint,
    keyLight: Light(
      id: 'key',
      position: vm.Vector3(3.0, 2.0, 4.0),
      color: Color(0xFFFFDDB3),
      intensity: 0.8,
    ),
    fillLight: Light(
      id: 'fill',
      position: vm.Vector3(-2.0, 0.5, 3.0),
      color: Color(0xFFB3D9FF),
      intensity: 0.3,
    ),
    backLight: Light(
      id: 'back',
      position: vm.Vector3(1.0, -1.0, -3.0),
      color: Color(0xFFFFCC99),
      intensity: 0.6,
    ),
    ambientLight: Light(
      id: 'ambient',
      position: vm.Vector3.zero(),
      color: Color(0xFF1A1A2E),
      intensity: 0.15,
    ),
  );

  static final neon = LightingPreset(
    name: 'Neon',
    mode: LightingMode.custom,
    keyLight: Light(
      id: 'key',
      position: vm.Vector3(0.0, 3.0, 5.0),
      color: Color(0xFFFF00FF),
      intensity: 1.2,
      audioReactive: true,
      audioSource: 'bassLevel',
      audioIntensity: 1.0,
    ),
    fillLight: Light(
      id: 'fill',
      position: vm.Vector3(-4.0, 0.0, 2.0),
      color: Color(0xFF00FFFF),
      intensity: 0.9,
      audioReactive: true,
      audioSource: 'presenceLevel',
      audioIntensity: 0.8,
    ),
    backLight: Light(
      id: 'back',
      position: vm.Vector3(4.0, 0.0, -2.0),
      color: Color(0xFFFFFF00),
      intensity: 0.8,
      audioReactive: true,
      audioSource: 'midLevel',
      audioIntensity: 0.7,
    ),
    ambientLight: Light(
      id: 'ambient',
      position: vm.Vector3.zero(),
      color: Color(0xFF0A0A0A),
      intensity: 0.05,
    ),
  );

  static final dramatic = LightingPreset(
    name: 'Dramatic',
    mode: LightingMode.threePoint,
    keyLight: Light(
      id: 'key',
      position: vm.Vector3(4.0, 4.0, 3.0),
      color: Colors.white,
      intensity: 1.5,
    ),
    fillLight: Light(
      id: 'fill',
      position: vm.Vector3(-1.0, 0.0, 2.0),
      color: Color(0xFF4444AA),
      intensity: 0.2,
    ),
    backLight: Light(
      id: 'back',
      position: vm.Vector3(0.0, -3.0, -4.0),
      color: Color(0xFFFFAA44),
      intensity: 0.9,
    ),
    ambientLight: Light(
      id: 'ambient',
      position: vm.Vector3.zero(),
      color: Color(0xFF000000),
      intensity: 0.0,
    ),
  );

  static List<LightingPreset> getAllPresets() {
    return [studio, stage, cinematic, neon, dramatic];
  }
}
