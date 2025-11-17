import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:mic_stream/mic_stream.dart';
import 'package:audio_session/audio_session.dart';
import '../utils/logger.dart';

/// Real-time audio input service with FFT analysis
class AudioInputService {
  StreamSubscription<Uint8List>? _audioSubscription;
  Stream<Uint8List>? _micStream;

  final int sampleRate = 44100;
  final int bufferSize = 4096; // Power of 2 for FFT

  final List<double> _audioBuffer = [];

  bool _isListening = false;
  bool get isListening => _isListening;

  // Callback for FFT data
  Function(Float32List fftMagnitudes)? onFFTData;

  AudioInputService();

  /// Start listening to microphone input
  Future<bool> startListening() async {
    if (_isListening) return true;

    try {
      // Configure audio session
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.measurement,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Start microphone stream
      _micStream = await MicStream.microphone(
        audioSource: AudioSource.DEFAULT,
        sampleRate: sampleRate,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      );

      _audioSubscription = _micStream!.listen(
        _onAudioData,
        onError: (error) {
          VIB3Logger.error('Audio stream error', 'AudioInput', error);
          stopListening();
        },
        onDone: () {
          VIB3Logger.info('Audio stream completed', 'AudioInput');
          stopListening();
        },
      );

      _isListening = true;
      VIB3Logger.success('Audio input started: $sampleRate Hz, buffer: $bufferSize', 'AudioInput');
      return true;
    } catch (e) {
      VIB3Logger.error('Failed to start audio input', 'AudioInput', e);
      _isListening = false;
      return false;
    }
  }

  /// Process incoming audio data
  void _onAudioData(Uint8List data) {
    // Convert PCM16 bytes to float samples (-1.0 to 1.0)
    for (int i = 0; i < data.length - 1; i += 2) {
      // Read 16-bit little-endian signed integer
      int sample = data[i] | (data[i + 1] << 8);
      if (sample > 32767) sample -= 65536; // Handle signed values

      // Normalize to -1.0 to 1.0
      double normalizedSample = sample / 32768.0;
      _audioBuffer.add(normalizedSample);
    }

    // Process when we have enough samples
    while (_audioBuffer.length >= bufferSize) {
      _processFFT(_audioBuffer.sublist(0, bufferSize));
      _audioBuffer.removeRange(0, bufferSize ~/ 2); // 50% overlap
    }
  }

  /// Perform FFT analysis on audio buffer (simplified radix-2 FFT)
  void _processFFT(List<double> samples) {
    // Apply Hann window to reduce spectral leakage
    final windowed = List<double>.generate(bufferSize, (i) {
      final windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (bufferSize - 1)));
      return samples[i] * windowValue;
    });

    // Perform simplified FFT using Cooley-Tukey algorithm
    final magnitudes = _fftMagnitude(windowed);

    // Normalize magnitudes to 0.0 - 1.0 range
    double maxMagnitude = magnitudes.reduce((a, b) => a > b ? a : b);
    if (maxMagnitude > 0) {
      for (int i = 0; i < magnitudes.length; i++) {
        magnitudes[i] = (magnitudes[i] / maxMagnitude).clamp(0.0, 1.0);
      }
    }

    // Send to callback
    if (onFFTData != null) {
      onFFTData!(magnitudes);
    }
  }

  /// Simple FFT magnitude calculation using Cooley-Tukey radix-2 algorithm
  Float32List _fftMagnitude(List<double> samples) {
    final n = samples.length;
    final realPart = List<double>.from(samples);
    final imagPart = List<double>.filled(n, 0.0);

    // Bit-reversal permutation
    int j = 0;
    for (int i = 0; i < n; i++) {
      if (i < j) {
        final tempReal = realPart[i];
        final tempImag = imagPart[i];
        realPart[i] = realPart[j];
        imagPart[i] = imagPart[j];
        realPart[j] = tempReal;
        imagPart[j] = tempImag;
      }
      int m = n ~/ 2;
      while (m >= 1 && j >= m) {
        j -= m;
        m ~/= 2;
      }
      j += m;
    }

    // Cooley-Tukey FFT
    int mmax = 1;
    while (n > mmax) {
      final istep = mmax * 2;
      final theta = -math.pi / mmax;
      for (int m = 0; m < mmax; m++) {
        final wReal = math.cos(m * theta);
        final wImag = math.sin(m * theta);
        for (int i = m; i < n; i += istep) {
          final j = i + mmax;
          final tempReal = wReal * realPart[j] - wImag * imagPart[j];
          final tempImag = wReal * imagPart[j] + wImag * realPart[j];
          realPart[j] = realPart[i] - tempReal;
          imagPart[j] = imagPart[i] - tempImag;
          realPart[i] += tempReal;
          imagPart[i] += tempImag;
        }
      }
      mmax = istep;
    }

    // Calculate magnitudes (only need first half of spectrum)
    final magnitudes = Float32List(n ~/ 2);
    for (int i = 0; i < n ~/ 2; i++) {
      magnitudes[i] = math.sqrt(realPart[i] * realPart[i] + imagPart[i] * imagPart[i]);
    }

    return magnitudes;
  }

  /// Stop listening to microphone input
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _micStream = null;
    _audioBuffer.clear();
    _isListening = false;

    VIB3Logger.info('Audio input stopped', 'AudioInput');
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
