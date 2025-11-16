import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../models/camera_system.dart';
import '../services/camera_rail_system.dart';
import '../providers/audio_provider.dart';

class CameraState {
  final CameraRailSystem system;
  final CameraPreset activePreset;

  const CameraState({
    required this.system,
    this.activePreset = CameraPreset.freeOrbit,
  });

  CameraState copyWith({
    CameraRailSystem? system,
    CameraPreset? activePreset,
  }) {
    return CameraState(
      system: system ?? this.system,
      activePreset: activePreset ?? this.activePreset,
    );
  }
}

class CameraNotifier extends StateNotifier<CameraState> {
  final Ref ref;

  CameraNotifier(this.ref)
      : super(CameraState(
          system: CameraRailSystem(),
        ));

  void update(double deltaTime) {
    final audioState = ref.read(audioProvider);
    state.system.update(deltaTime, audioState.beatEngine);
  }

  void setPreset(CameraPreset preset) {
    state.system.setMode(preset);
    state = state.copyWith(activePreset: preset);
  }

  void setFreeOrbitAngles(double yaw, double pitch, double distance) {
    state.system.setFreeOrbitAngles(yaw, pitch, distance);
  }

  void setFOV(double fov) {
    state.system.setFOV(fov);
  }

  void addRail(CameraRail rail) {
    state.system.addRail(rail);
  }

  void removeRail(int index) {
    state.system.removeRail(index);
  }

  vm.Vector3 getPosition() => state.system.getPosition();
  vm.Vector3 getTarget() => state.system.getTarget();
  double getFOV() => state.system.getFOV();

  List<CameraRail> getRails() => state.system.rails;
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier(ref);
});
