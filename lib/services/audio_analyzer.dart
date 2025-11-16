import 'dart:math';
import 'dart:typed_data';
import '../models/audio_band.dart';

class SevenBandAudioAnalyzer {
  // Frequency band levels (0.0 - 1.0)
  List<double> bandLevels = List.filled(7, 0.0);
  List<double> bandPeaks = List.filled(7, 0.0);
  List<double> onsetHistory = List.filled(10, 0.0);

  double onsetThreshold = 0.4;
  double onsetSensitivity = 0.5;
  bool onsetDetected = false;

  // Overall metrics
  double overallVolume = 0.0;

  // Convenience getters
  double get subLevel => bandLevels[0];
  double get bassLevel => bandLevels[1];
  double get lowMidLevel => bandLevels[2];
  double get midLevel => bandLevels[3];
  double get highMidLevel => bandLevels[4];
  double get presenceLevel => bandLevels[5];
  double get airLevel => bandLevels[6];

  void analyze(Float32List fftData, int sampleRate) {
    final binSize = sampleRate / fftData.length;

    // Analyze each frequency band
    for (var i = 0; i < SevenBandAnalyzer.bands.length; i++) {
      final band = SevenBandAnalyzer.bands[i];
      final startBin = (band.minFreq / binSize).floor();
      final endBin = (band.maxFreq / binSize).ceil().clamp(0, fftData.length);

      // Calculate RMS energy in this band
      double energy = 0.0;
      for (var bin = startBin; bin < endBin; bin++) {
        energy += fftData[bin] * fftData[bin];
      }
      energy = sqrt(energy / (endBin - startBin).clamp(1, double.infinity));

      // Smooth with previous value (exponential moving average)
      bandLevels[i] = bandLevels[i] * 0.7 + energy * 0.3;

      // Track peaks with decay
      bandPeaks[i] = max(bandPeaks[i] * 0.95, bandLevels[i]);
    }

    // Calculate overall volume (RMS of all frequencies)
    overallVolume = bandLevels.reduce((a, b) => a + b) / bandLevels.length;

    // Onset detection (transient analysis)
    _detectOnsets();
  }

  void _detectOnsets() {
    // Calculate spectral flux (change in spectrum)
    double flux = 0.0;
    for (var i = 0; i < bandLevels.length; i++) {
      final diff = max(0.0, bandLevels[i] - (onsetHistory.isNotEmpty ? onsetHistory.first : 0.0));
      flux += diff * diff;
    }
    flux = sqrt(flux);

    // Update onset history
    onsetHistory.insert(0, flux);
    if (onsetHistory.length > 10) onsetHistory.removeLast();

    // Calculate adaptive threshold
    final meanFlux = onsetHistory.reduce((a, b) => a + b) / onsetHistory.length;
    final threshold = meanFlux * (1.0 + onsetSensitivity);

    // Detect onset
    onsetDetected = flux > threshold && flux > onsetThreshold;
  }

  double getBandLevel(AudioSource source) {
    switch (source) {
      case AudioSource.subLevel:
        return subLevel;
      case AudioSource.bassLevel:
        return bassLevel;
      case AudioSource.lowMidLevel:
        return lowMidLevel;
      case AudioSource.midLevel:
        return midLevel;
      case AudioSource.highMidLevel:
        return highMidLevel;
      case AudioSource.presenceLevel:
        return presenceLevel;
      case AudioSource.airLevel:
        return airLevel;
      case AudioSource.overallVolume:
        return overallVolume;
      default:
        return 0.0;
    }
  }

  void reset() {
    bandLevels.fillRange(0, bandLevels.length, 0.0);
    bandPeaks.fillRange(0, bandPeaks.length, 0.0);
    onsetHistory.fillRange(0, onsetHistory.length, 0.0);
    overallVolume = 0.0;
    onsetDetected = false;
  }
}
