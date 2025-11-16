import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline.dart';
import '../models/vib3_parameters.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  Timer? _playbackTimer;

  TimelineNotifier()
      : super(const TimelineState(
          tracks: [],
          duration: 32.0,
        ));

  void play() {
    if (state.isPlaying) return;

    state = state.copyWith(isPlaying: true);

    // Start playback timer (60 FPS)
    _playbackTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      _updatePlayhead();
    });
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void stop() {
    state = state.copyWith(isPlaying: false, playhead: 0.0);
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _updatePlayhead() {
    if (!state.isPlaying) return;

    double newPlayhead = state.playhead + 0.016; // 16ms per frame

    if (newPlayhead >= state.duration) {
      if (state.isLooping) {
        newPlayhead = newPlayhead % state.duration;
      } else {
        newPlayhead = state.duration;
        pause();
      }
    }

    state = state.copyWith(playhead: newPlayhead);
  }

  void seek(double time) {
    state = state.copyWith(
      playhead: time.clamp(0.0, state.duration),
    );
  }

  void setDuration(double duration) {
    state = state.copyWith(duration: duration);
  }

  void toggleLooping() {
    state = state.copyWith(isLooping: !state.isLooping);
  }

  void setBPM(double bpm) {
    state = state.copyWith(bpm: bpm);
  }

  void setTimeSignature(int beats, int note) {
    state = state.copyWith(
      timeSignatureBeats: beats,
      timeSignatureNote: note,
    );
  }

  void addTrack(TimelineTrack track) {
    final newTracks = List<TimelineTrack>.from(state.tracks);
    newTracks.add(track);
    state = state.copyWith(tracks: newTracks);
  }

  void removeTrack(String trackId) {
    final newTracks = state.tracks.where((t) => t.id != trackId).toList();
    state = state.copyWith(tracks: newTracks);
  }

  void toggleTrack(String trackId) {
    final newTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        return TimelineTrack(
          id: track.id,
          name: track.name,
          type: track.type,
          targetParameter: track.targetParameter,
          curve: track.curve,
          triggerPoints: track.triggerPoints,
          enabled: !track.enabled,
        );
      }
      return track;
    }).toList();
    state = state.copyWith(tracks: newTracks);
  }

  Map<VIB3Parameters, num> getActiveParameters() {
    final result = <VIB3Parameters, num>{};

    for (final track in state.tracks) {
      if (!track.enabled || track.targetParameter == null) continue;

      switch (track.type) {
        case TrackType.parameterAutomation:
          if (track.curve != null) {
            final value = track.curve!.getValueAt(state.playhead);
            result[track.targetParameter!] = value;
          }
          break;

        case TrackType.beatTrigger:
          // Check if playhead is near any trigger point
          if (track.triggerPoints != null) {
            for (final triggerTime in track.triggerPoints!) {
              if ((state.playhead - triggerTime).abs() < 0.05) {
                // Within 50ms of trigger
                result[track.targetParameter!] = 1.0;
                break;
              }
            }
          }
          break;

        case TrackType.geometryChange:
        case TrackType.paletteSwap:
          // These are handled separately
          break;
      }
    }

    return result;
  }

  void loadPreset(TimelinePreset preset) {
    state = TimelineState(
      tracks: preset.tracks,
      duration: preset.duration,
      playhead: 0.0,
      isPlaying: false,
      isLooping: state.isLooping,
      bpm: state.bpm,
      timeSignatureBeats: state.timeSignatureBeats,
      timeSignatureNote: state.timeSignatureNote,
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

final timelineProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
  return TimelineNotifier();
});
