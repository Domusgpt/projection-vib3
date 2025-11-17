import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline.dart';
import '../models/vib3_parameters.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  Timer? _playbackTimer;

  TimelineNotifier()
      : super(const TimelineState(
          tracks: [],
          totalDuration: 60.0,
          playheadPosition: 0.0,
          isPlaying: false,
          isLooping: false,
          syncToBPM: false,
          bpm: 128.0,
          timeSignature: TimeSignature.fourFour,
        ));

  void play() {
    if (state.isPlaying) return;

    state = state.copyWith(isPlaying: true);

    // Start playback timer (60 FPS)
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updatePlayhead();
    });
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void stop() {
    state = state.copyWith(isPlaying: false, playheadPosition: 0.0);
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _updatePlayhead() {
    if (!state.isPlaying) return;

    double newPlayhead = state.playheadPosition + 0.016; // 16ms per frame

    if (newPlayhead >= state.totalDuration) {
      if (state.isLooping) {
        newPlayhead = newPlayhead % state.totalDuration;
      } else {
        newPlayhead = state.totalDuration;
        pause();
      }
    }

    state = state.copyWith(playheadPosition: newPlayhead);
  }

  void seek(double time) {
    state = state.copyWith(
      playheadPosition: time.clamp(0.0, state.totalDuration),
    );
  }

  void setDuration(double duration) {
    state = state.copyWith(totalDuration: duration);
  }

  void toggleLoop() {
    state = state.copyWith(isLooping: !state.isLooping);
  }

  void toggleBPMSync() {
    state = state.copyWith(syncToBPM: !state.syncToBPM);
  }

  void setBPM(double bpm) {
    state = state.copyWith(bpm: bpm);
  }

  void setTimeSignature(TimeSignature signature) {
    state = state.copyWith(timeSignature: signature);
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

  void toggleTrackMute(String trackId) {
    final newTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(isMuted: !track.isMuted);
      }
      return track;
    }).toList();
    state = state.copyWith(tracks: newTracks);
  }

  void addKeyframe(String trackId, TimelineKeyframe keyframe) {
    final newTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        final newKeyframes = List<TimelineKeyframe>.from(track.keyframes);
        newKeyframes.add(keyframe);
        // Sort by time
        newKeyframes.sort((a, b) => a.time.compareTo(b.time));
        return track.copyWith(keyframes: newKeyframes);
      }
      return track;
    }).toList();
    state = state.copyWith(tracks: newTracks);
  }

  void removeKeyframe(String trackId, int keyframeIndex) {
    final newTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        final newKeyframes = List<TimelineKeyframe>.from(track.keyframes);
        if (keyframeIndex >= 0 && keyframeIndex < newKeyframes.length) {
          newKeyframes.removeAt(keyframeIndex);
        }
        return track.copyWith(keyframes: newKeyframes);
      }
      return track;
    }).toList();
    state = state.copyWith(tracks: newTracks);
  }

  void updateKeyframe(
      String trackId, int keyframeIndex, TimelineKeyframe newKeyframe) {
    final newTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        final newKeyframes = List<TimelineKeyframe>.from(track.keyframes);
        if (keyframeIndex >= 0 && keyframeIndex < newKeyframes.length) {
          newKeyframes[keyframeIndex] = newKeyframe;
          // Resort by time
          newKeyframes.sort((a, b) => a.time.compareTo(b.time));
        }
        return track.copyWith(keyframes: newKeyframes);
      }
      return track;
    }).toList();
    state = state.copyWith(tracks: newTracks);
  }

  /// Get parameter values at current playhead position
  Map<VIB3Parameters, num> getActiveParameters() {
    final result = <VIB3Parameters, num>{};

    for (final track in state.tracks) {
      if (track.isMuted || track.targetParameter == null) continue;

      // Get interpolated value from track's keyframes
      final value = track.getValueAt(state.playheadPosition);
      result[track.targetParameter!] = value;
    }

    return result;
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
