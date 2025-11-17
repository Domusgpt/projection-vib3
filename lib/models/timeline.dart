import '../models/vib3_parameters.dart';

enum TimelineTrackType {
  parameter,
  camera,
  lighting,
  color,
}

class TimelineKeyframe {
  final double time;
  final double value;
  final String? easing;

  const TimelineKeyframe({
    required this.time,
    required this.value,
    this.easing,
  });

  TimelineKeyframe copyWith({
    double? time,
    double? value,
    String? easing,
  }) {
    return TimelineKeyframe(
      time: time ?? this.time,
      value: value ?? this.value,
      easing: easing ?? this.easing,
    );
  }
}

class TimelineTrack {
  final String id;
  final String name;
  final TimelineTrackType type;
  final VIB3Parameters? targetParameter;
  final List<TimelineKeyframe> keyframes;
  final bool isMuted;

  const TimelineTrack({
    required this.id,
    required this.name,
    required this.type,
    this.targetParameter,
    this.keyframes = const [],
    this.isMuted = false,
  });

  TimelineTrack copyWith({
    String? id,
    String? name,
    TimelineTrackType? type,
    VIB3Parameters? targetParameter,
    List<TimelineKeyframe>? keyframes,
    bool? isMuted,
  }) {
    return TimelineTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetParameter: targetParameter ?? this.targetParameter,
      keyframes: keyframes ?? this.keyframes,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  double getValueAt(double time) {
    if (keyframes.isEmpty) return 0.0;
    if (keyframes.length == 1) return keyframes.first.value;

    // Find surrounding keyframes
    for (int i = 0; i < keyframes.length - 1; i++) {
      if (time >= keyframes[i].time && time <= keyframes[i + 1].time) {
        // Linear interpolation
        final t = (time - keyframes[i].time) /
            (keyframes[i + 1].time - keyframes[i].time);
        return keyframes[i].value +
            (keyframes[i + 1].value - keyframes[i].value) * t;
      }
    }

    // Return last keyframe value if time is beyond
    return keyframes.last.value;
  }
}

enum TimeSignature {
  fourFour,
  threeFour,
  sixEight,
  sevenEight,
}

class TimelineState {
  final List<TimelineTrack> tracks;
  final double totalDuration;
  final double playheadPosition;
  final bool isPlaying;
  final bool isLooping;
  final bool syncToBPM;
  final double bpm;
  final TimeSignature timeSignature;

  const TimelineState({
    this.tracks = const [],
    this.totalDuration = 60.0,
    this.playheadPosition = 0.0,
    this.isPlaying = false,
    this.isLooping = false,
    this.syncToBPM = false,
    this.bpm = 128.0,
    this.timeSignature = TimeSignature.fourFour,
  });

  TimelineState copyWith({
    List<TimelineTrack>? tracks,
    double? totalDuration,
    double? playheadPosition,
    bool? isPlaying,
    bool? isLooping,
    bool? syncToBPM,
    double? bpm,
    TimeSignature? timeSignature,
  }) {
    return TimelineState(
      tracks: tracks ?? this.tracks,
      totalDuration: totalDuration ?? this.totalDuration,
      playheadPosition: playheadPosition ?? this.playheadPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      syncToBPM: syncToBPM ?? this.syncToBPM,
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
    );
  }

  int get currentMeasure {
    final beatsPerMeasure = _getBeatsPerMeasure();
    final beatDuration = 60.0 / bpm;
    final measureDuration = beatDuration * beatsPerMeasure;
    return (playheadPosition / measureDuration).floor() + 1;
  }

  int get currentBeat {
    final beatDuration = 60.0 / bpm;
    final beatsPerMeasure = _getBeatsPerMeasure();
    final measureDuration = beatDuration * beatsPerMeasure;
    final beatInMeasure = (playheadPosition % measureDuration) / beatDuration;
    return beatInMeasure.floor() + 1;
  }

  int _getBeatsPerMeasure() {
    switch (timeSignature) {
      case TimeSignature.fourFour:
        return 4;
      case TimeSignature.threeFour:
        return 3;
      case TimeSignature.sixEight:
        return 6;
      case TimeSignature.sevenEight:
        return 7;
    }
  }
}
