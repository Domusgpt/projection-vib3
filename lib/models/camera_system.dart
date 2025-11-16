import 'dart:math';
import 'package:vector_math/vector_math.dart' as vm;

enum CameraPreset {
  freeOrbit,
  cinematicRail1,
  cinematicRail2,
  cinematicRail3,
  preset1,
  preset2,
  preset3,
  preset4,
  preset5,
  preset6,
  preset7,
  preset8,
}

enum PathType {
  linear,
  circular,
  bezier,
  figure8,
}

enum LoopMode {
  once,
  loop,
  pingPong,
}

enum EasingType {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  bounce,
}

class CameraKeyframe {
  final vm.Vector3 position;
  final vm.Vector3 target;
  final double timestamp; // 0.0 - 1.0

  const CameraKeyframe({
    required this.position,
    required this.target,
    required this.timestamp,
  });
}

class CameraRail {
  final String name;
  final List<CameraKeyframe> keyframes;
  final PathType pathType;
  final EasingType easing;
  final LoopMode loopMode;
  final double duration; // seconds
  final bool beatSynced;
  final bool audioReactive;
  final double audioIntensity;

  double progress = 0.0;
  int direction = 1;

  CameraRail({
    required this.name,
    required this.keyframes,
    this.pathType = PathType.linear,
    this.easing = EasingType.linear,
    this.loopMode = LoopMode.loop,
    this.duration = 30.0,
    this.beatSynced = false,
    this.audioReactive = false,
    this.audioIntensity = 0.5,
  });

  vm.Vector3 getPositionAt(double t) {
    t = applyEasing(t);

    switch (pathType) {
      case PathType.linear:
        return _interpolateLinear(t);
      case PathType.circular:
        return _interpolateCircular(t);
      case PathType.bezier:
        return _interpolateBezier(t);
      case PathType.figure8:
        return _interpolateFigure8(t);
    }
  }

  vm.Vector3 _interpolateLinear(double t) {
    if (keyframes.isEmpty) return vm.Vector3.zero();
    if (keyframes.length == 1) return keyframes[0].position;

    // Find surrounding keyframes
    for (int i = 0; i < keyframes.length - 1; i++) {
      if (t >= keyframes[i].timestamp && t <= keyframes[i + 1].timestamp) {
        final localT = (t - keyframes[i].timestamp) /
            (keyframes[i + 1].timestamp - keyframes[i].timestamp);
        return vm.Vector3(
          keyframes[i].position.x +
              (keyframes[i + 1].position.x - keyframes[i].position.x) * localT,
          keyframes[i].position.y +
              (keyframes[i + 1].position.y - keyframes[i].position.y) * localT,
          keyframes[i].position.z +
              (keyframes[i + 1].position.z - keyframes[i].position.z) * localT,
        );
      }
    }

    return keyframes.last.position;
  }

  vm.Vector3 _interpolateCircular(double t) {
    if (keyframes.isEmpty) return vm.Vector3.zero();
    final angle = t * 2 * pi;
    final radius = keyframes[0].position.length;
    return vm.Vector3(
      cos(angle) * radius,
      sin(angle) * radius,
      keyframes[0].position.z,
    );
  }

  vm.Vector3 _interpolateBezier(double t) {
    // Cubic Bezier interpolation
    if (keyframes.length < 4) return _interpolateLinear(t);

    final p0 = keyframes[0].position;
    final p1 = keyframes[1].position;
    final p2 = keyframes[2].position;
    final p3 = keyframes[3].position;

    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    return (p0 * uuu) + (p1 * (3 * uu * t)) + (p2 * (3 * u * tt)) + (p3 * ttt);
  }

  vm.Vector3 _interpolateFigure8(double t) {
    final angle = t * 2 * pi;
    final radius = keyframes.isNotEmpty ? keyframes[0].position.length : 5.0;
    return vm.Vector3(
      radius * sin(angle),
      radius * sin(angle) * cos(angle),
      keyframes.isNotEmpty ? keyframes[0].position.z : 0.0,
    );
  }

  double applyEasing(double t) {
    switch (easing) {
      case EasingType.linear:
        return t;
      case EasingType.easeIn:
        return t * t;
      case EasingType.easeOut:
        return 1 - (1 - t) * (1 - t);
      case EasingType.easeInOut:
        return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
      case EasingType.bounce:
        if (t < 1 / 2.75) {
          return 7.5625 * t * t;
        } else if (t < 2 / 2.75) {
          final t2 = t - 1.5 / 2.75;
          return 7.5625 * t2 * t2 + 0.75;
        } else if (t < 2.5 / 2.75) {
          final t2 = t - 2.25 / 2.75;
          return 7.5625 * t2 * t2 + 0.9375;
        } else {
          final t2 = t - 2.625 / 2.75;
          return 7.5625 * t2 * t2 + 0.984375;
        }
    }
  }
}
