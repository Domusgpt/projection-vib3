import '../models/vib3_parameters.dart';

enum TrackType {
  parameterAutomation,
  beatTrigger,
  geometryChange,
  paletteSwap,
}

class TimelineKeyframe {
  final double timestamp; // in seconds
  final VIB3Parameters? parameter;
  final num value;

  const TimelineKeyframe({
    required this.timestamp,
    this.parameter,
    required this.value,
  });
}

class AutomationCurve {
  final List<TimelineKeyframe> keyframes;
  final bool isSmooth; // true = curved interpolation, false = stepped

  const AutomationCurve({
    required this.keyframes,
    this.isSmooth = true,
  });

  num getValueAt(double time) {
    if (keyframes.isEmpty) return 0;
    if (keyframes.length == 1) return keyframes[0].value;

    // Find surrounding keyframes
    for (int i = 0; i < keyframes.length - 1; i++) {
      if (time >= keyframes[i].timestamp &&
          time <= keyframes[i + 1].timestamp) {
        if (!isSmooth) {
          // Stepped - return current keyframe value
          return keyframes[i].value;
        }

        // Linear interpolation
        final t = (time - keyframes[i].timestamp) /
            (keyframes[i + 1].timestamp - keyframes[i].timestamp);
        return keyframes[i].value +
            (keyframes[i + 1].value - keyframes[i].value) * t;
      }
    }

    // Return last keyframe value if time is beyond last keyframe
    return keyframes.last.value;
  }
}

class TimelineTrack {
  final String id;
  final String name;
  final TrackType type;
  final VIB3Parameters? targetParameter;
  final AutomationCurve? curve;
  final List<double>? triggerPoints; // For beat triggers
  final bool enabled;

  const TimelineTrack({
    required this.id,
    required this.name,
    required this.type,
    this.targetParameter,
    this.curve,
    this.triggerPoints,
    this.enabled = true,
  });
}

class TimelineState {
  final List<TimelineTrack> tracks;
  final double duration; // Total duration in seconds
  final double playhead; // Current position in seconds
  final bool isPlaying;
  final bool isLooping;
  final double bpm;
  final int timeSignatureBeats;
  final int timeSignatureNote;

  const TimelineState({
    required this.tracks,
    this.duration = 32.0,
    this.playhead = 0.0,
    this.isPlaying = false,
    this.isLooping = true,
    this.bpm = 128.0,
    this.timeSignatureBeats = 4,
    this.timeSignatureNote = 4,
  });

  TimelineState copyWith({
    List<TimelineTrack>? tracks,
    double? duration,
    double? playhead,
    bool? isPlaying,
    bool? isLooping,
    double? bpm,
    int? timeSignatureBeats,
    int? timeSignatureNote,
  }) {
    return TimelineState(
      tracks: tracks ?? this.tracks,
      duration: duration ?? this.duration,
      playhead: playhead ?? this.playhead,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      bpm: bpm ?? this.bpm,
      timeSignatureBeats: timeSignatureBeats ?? this.timeSignatureBeats,
      timeSignatureNote: timeSignatureNote ?? this.timeSignatureNote,
    );
  }

  double get measureDuration {
    // Calculate duration of one measure in seconds
    return (60.0 / bpm) * timeSignatureBeats;
  }

  int get currentMeasure {
    return (playhead / measureDuration).floor() + 1;
  }

  int get currentBeat {
    final beatDuration = 60.0 / bpm;
    final beatInMeasure = (playhead % measureDuration) / beatDuration;
    return beatInMeasure.floor() + 1;
  }

  double get beatProgress {
    final beatDuration = 60.0 / bpm;
    final beatPosition = playhead % beatDuration;
    return beatPosition / beatDuration;
  }
}

class TimelinePreset {
  final String name;
  final List<TimelineTrack> tracks;
  final double duration;

  const TimelinePreset({
    required this.name,
    required this.tracks,
    this.duration = 32.0,
  });

  static final presets = [
    TimelinePreset(
      name: 'Intro',
      tracks: [],
      duration: 16.0,
    ),
    TimelinePreset(
      name: 'Build',
      tracks: [],
      duration: 16.0,
    ),
    TimelinePreset(
      name: 'Drop',
      tracks: [],
      duration: 32.0,
    ),
    TimelinePreset(
      name: 'Breakdown',
      tracks: [],
      duration: 16.0,
    ),
  ];
}
