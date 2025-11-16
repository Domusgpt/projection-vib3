import 'package:vector_math/vector_math.dart' as vm;
import '../models/camera_system.dart';
import '../services/beat_detector.dart';

class CameraRailSystem {
  List<CameraRail> rails = [];
  CameraPreset currentMode = CameraPreset.freeOrbit;
  vm.Vector3 currentPosition = vm.Vector3(0, 0, 5);
  vm.Vector3 currentTarget = vm.Vector3.zero();
  double currentFOV = 75.0;

  // Free orbit state
  double orbitYaw = 0.0;
  double orbitPitch = 0.0;
  double orbitDistance = 5.0;

  CameraRailSystem() {
    _initializeDefaultRails();
  }

  void _initializeDefaultRails() {
    // Cinematic Rail 1: Circular orbit
    rails.add(CameraRail(
      name: 'Cinematic Rail 1',
      keyframes: [
        CameraKeyframe(
          position: vm.Vector3(5, 0, 0),
          target: vm.Vector3.zero(),
          timestamp: 0.0,
        ),
        CameraKeyframe(
          position: vm.Vector3(0, 0, 5),
          target: vm.Vector3.zero(),
          timestamp: 0.25,
        ),
        CameraKeyframe(
          position: vm.Vector3(-5, 0, 0),
          target: vm.Vector3.zero(),
          timestamp: 0.5,
        ),
        CameraKeyframe(
          position: vm.Vector3(0, 0, -5),
          target: vm.Vector3.zero(),
          timestamp: 0.75,
        ),
      ],
      pathType: PathType.circular,
      easing: EasingType.linear,
      loopMode: LoopMode.loop,
      duration: 30.0,
    ));

    // Cinematic Rail 2: Zoom in/out
    rails.add(CameraRail(
      name: 'Cinematic Rail 2',
      keyframes: [
        CameraKeyframe(
          position: vm.Vector3(0, 0, 10),
          target: vm.Vector3.zero(),
          timestamp: 0.0,
        ),
        CameraKeyframe(
          position: vm.Vector3(0, 0, 3),
          target: vm.Vector3.zero(),
          timestamp: 0.5,
        ),
        CameraKeyframe(
          position: vm.Vector3(0, 0, 10),
          target: vm.Vector3.zero(),
          timestamp: 1.0,
        ),
      ],
      pathType: PathType.linear,
      easing: EasingType.easeInOut,
      loopMode: LoopMode.loop,
      duration: 16.0,
      beatSynced: true,
      audioReactive: true,
      audioIntensity: 0.5,
    ));

    // Cinematic Rail 3: Figure-8 path
    rails.add(CameraRail(
      name: 'Cinematic Rail 3',
      keyframes: [
        CameraKeyframe(
          position: vm.Vector3(0, 0, 5),
          target: vm.Vector3.zero(),
          timestamp: 0.0,
        ),
      ],
      pathType: PathType.figure8,
      easing: EasingType.linear,
      loopMode: LoopMode.loop,
      duration: 32.0,
      beatSynced: true,
    ));
  }

  void update(double deltaTime, AudioBeatEngine? beatEngine) {
    if (currentMode.index >= CameraPreset.cinematicRail1.index &&
        currentMode.index <= CameraPreset.cinematicRail3.index) {
      // Active rail mode
      final railIndex = currentMode.index - CameraPreset.cinematicRail1.index;
      if (railIndex < rails.length) {
        final rail = rails[railIndex];

        // Update progress
        if (rail.beatSynced && beatEngine != null) {
          rail.progress = beatEngine.measureProgress;
        } else {
          rail.progress += deltaTime / rail.duration;
        }

        // Handle looping
        if (rail.progress >= 1.0) {
          switch (rail.loopMode) {
            case LoopMode.once:
              rail.progress = 1.0;
              break;
            case LoopMode.loop:
              rail.progress = rail.progress % 1.0;
              break;
            case LoopMode.pingPong:
              rail.direction *= -1;
              rail.progress = 0.0;
              break;
          }
        }

        // Calculate camera position
        currentPosition = rail.getPositionAt(rail.progress);
        currentTarget = vm.Vector3.zero(); // Always look at origin for now

        // Apply audio reactivity
        if (rail.audioReactive && beatEngine != null) {
          // Pulse the camera distance on beats
          final bassReactive = 0.0; // TODO: Get from audio analyzer
          currentPosition = currentPosition * (1.0 + bassReactive * rail.audioIntensity * 0.2);
        }
      }
    } else if (currentMode == CameraPreset.freeOrbit) {
      // Free orbit mode - calculate position from spherical coordinates
      currentPosition = vm.Vector3(
        orbitDistance * cos(orbitPitch) * sin(orbitYaw),
        orbitDistance * sin(orbitPitch),
        orbitDistance * cos(orbitPitch) * cos(orbitYaw),
      );
      currentTarget = vm.Vector3.zero();
    }
  }

  void setMode(CameraPreset mode) {
    currentMode = mode;

    // Reset rail progress when switching to rail mode
    if (mode.index >= CameraPreset.cinematicRail1.index &&
        mode.index <= CameraPreset.cinematicRail3.index) {
      final railIndex = mode.index - CameraPreset.cinematicRail1.index;
      if (railIndex < rails.length) {
        rails[railIndex].progress = 0.0;
      }
    }
  }

  void setFreeOrbitAngles(double yaw, double pitch, double distance) {
    orbitYaw = yaw;
    orbitPitch = pitch;
    orbitDistance = distance;
  }

  void addRail(CameraRail rail) {
    rails.add(rail);
  }

  void removeRail(int index) {
    if (index >= 0 && index < rails.length) {
      rails.removeAt(index);
    }
  }

  vm.Vector3 getPosition() => currentPosition;
  vm.Vector3 getTarget() => currentTarget;
  double getFOV() => currentFOV;

  void setFOV(double fov) {
    currentFOV = fov.clamp(30.0, 120.0);
  }
}
