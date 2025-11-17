import 'dart:collection';
import 'dart:math';

enum TimeSignature {
  threeQuarter(3, 4),
  fourFour(4, 4),
  fiveFour(5, 4),
  sixEight(6, 8),
  sevenEight(7, 8);

  final int beatsPerMeasure;
  final int noteValue;

  const TimeSignature(this.beatsPerMeasure, this.noteValue);
}

class AudioBeatEngine {
  double bpm = 128.0;
  bool autoDetect = true;
  TimeSignature timeSignature = TimeSignature.fourFour;

  int currentMeasure = 1;
  int currentBeat = 1;
  double beatProgress = 0.0; // 0.0 - 1.0 within current beat
  double measureProgress = 0.0; // 0.0 - 1.0 within current measure

  // Beat detection
  bool kickDetected = false;
  double kickThreshold = 0.6;
  int beatsSinceDownbeat = 0;
  DateTime? lastBeatTime;

  // BPM detection
  Queue<DateTime> recentBeats = Queue();
  int maxBeatHistory = 8;

  // LFO (Low Frequency Oscillator) for BPM-synced modulation
  double lfoPhase = 0.0;

  void update(double deltaTime, {double? bassLevel, bool? beatTriggered}) {
    // Update beat progress
    final beatDuration = 60.0 / bpm;
    beatProgress += deltaTime / beatDuration;

    if (beatProgress >= 1.0) {
      _advanceBeat();
      beatProgress = beatProgress % 1.0;
    }

    // Manual beat detection from bass level
    if (beatTriggered == true || (bassLevel != null && bassLevel > kickThreshold)) {
      if (!kickDetected) {
        _onBeatDetected();
      }
      kickDetected = true;
    } else {
      kickDetected = false;
    }

    // Update measure progress
    measureProgress = beatsSinceDownbeat / timeSignature.beatsPerMeasure;

    // Update LFO
    lfoPhase += deltaTime * (bpm / 60.0);
    lfoPhase = lfoPhase % 1.0;
  }

  void _advanceBeat() {
    currentBeat++;
    beatsSinceDownbeat++;

    if (beatsSinceDownbeat >= timeSignature.beatsPerMeasure) {
      currentMeasure++;
      beatsSinceDownbeat = 0;
    }
  }

  void _onBeatDetected() {
    final now = DateTime.now();

    // Auto-detect BPM from beat intervals
    if (autoDetect && lastBeatTime != null) {
      // Calculate BPM from interval (could be used for auto-BPM detection in future)
      // final interval = now.difference(lastBeatTime!).inMilliseconds;
      // final detectedBPM = 60000.0 / interval;

      // Add to history
      recentBeats.add(now);
      if (recentBeats.length > maxBeatHistory) {
        recentBeats.removeFirst();
      }

      // Calculate average BPM from recent beats
      if (recentBeats.length >= 4) {
        final avgInterval = _calculateAverageBeatInterval();
        final avgBPM = 60000.0 / avgInterval;

        // Only update if reasonably close to current BPM (avoid wild jumps)
        if ((avgBPM - bpm).abs() < 20 || bpm == 128.0) {
          bpm = avgBPM;
        }
      }
    }

    lastBeatTime = now;
  }

  double _calculateAverageBeatInterval() {
    if (recentBeats.length < 2) return 60000.0 / bpm;

    double totalInterval = 0.0;
    DateTime? prev;

    for (var beat in recentBeats) {
      if (prev != null) {
        totalInterval += beat.difference(prev).inMilliseconds;
      }
      prev = beat;
    }

    return totalInterval / (recentBeats.length - 1);
  }

  double getBPMConfidence() {
    if (recentBeats.length < 4) return 0.0;

    // Calculate variance in beat intervals
    final avgInterval = _calculateAverageBeatInterval();
    double variance = 0.0;

    DateTime? prev;
    for (var beat in recentBeats) {
      if (prev != null) {
        final interval = beat.difference(prev).inMilliseconds.toDouble();
        variance += pow(interval - avgInterval, 2);
      }
      prev = beat;
    }

    variance /= (recentBeats.length - 1);
    final stdDev = sqrt(variance);

    // Confidence inversely proportional to variance
    // Low variance = high confidence
    final confidence = 1.0 - (stdDev / avgInterval).clamp(0.0, 1.0);
    return confidence;
  }

  // LFO waveform generators (BPM-synced)
  double getLFOSine() => sin(lfoPhase * 2 * pi) * 0.5 + 0.5;
  double getLFOSaw() => lfoPhase;
  double getLFOSquare() => lfoPhase < 0.5 ? 0.0 : 1.0;
  double getLFOTriangle() => lfoPhase < 0.5 ? lfoPhase * 2 : 2.0 - lfoPhase * 2;

  void setBPM(double newBPM) {
    bpm = newBPM.clamp(60.0, 200.0);
  }

  void setTimeSignature(TimeSignature sig) {
    timeSignature = sig;
    beatsSinceDownbeat = beatsSinceDownbeat % sig.beatsPerMeasure;
  }

  void reset() {
    currentMeasure = 1;
    currentBeat = 1;
    beatProgress = 0.0;
    measureProgress = 0.0;
    beatsSinceDownbeat = 0;
    kickDetected = false;
    lastBeatTime = null;
    recentBeats.clear();
    lfoPhase = 0.0;
  }

  void tap() {
    // Manual tap tempo
    _onBeatDetected();
  }
}
