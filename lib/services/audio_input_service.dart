import 'dart:async';
import 'dart:typed_data';
import 'package:mic_stream/mic_stream.dart';
import 'package:audio_session/audio_session.dart';
import 'package:fft/fft.dart';

/// Real-time audio input service with FFT analysis
class AudioInputService {
  StreamSubscription<Uint8List>? _audioSubscription;
  Stream<Uint8List>? _micStream;

  final int sampleRate = 44100;
  final int bufferSize = 4096; // Power of 2 for FFT

  late FFT _fft;
  List<double> _audioBuffer = [];

  bool _isListening = false;
  bool get isListening => _isListening;

  // Callback for FFT data
  Function(Float32List fftMagnitudes)? onFFTData;

  AudioInputService() {
    _fft = FFT(bufferSize);
  }

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
          print('Audio stream error: $error');
          stopListening();
        },
        onDone: () {
          print('Audio stream completed');
          stopListening();
        },
      );

      _isListening = true;
      print('Audio input started: $sampleRate Hz, buffer size: $bufferSize');
      return true;
    } catch (e) {
      print('Failed to start audio input: $e');
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

  /// Perform FFT analysis on audio buffer
  void _processFFT(List<double> samples) {
    // Apply Hann window to reduce spectral leakage
    final windowed = List<double>.generate(bufferSize, (i) {
      final windowValue = 0.5 * (1 - (2 * 3.14159265359 * i / (bufferSize - 1)).cos());
      return samples[i] * windowValue;
    });

    // Perform FFT
    final fftResult = _fft.realFft(windowed);

    // Calculate magnitudes (only need first half of spectrum)
    final magnitudes = Float32List(bufferSize ~/ 2);
    for (int i = 0; i < bufferSize ~/ 2; i++) {
      final real = fftResult[i];
      final imag = i < fftResult.length - 1 ? fftResult[i + 1] : 0.0;
      magnitudes[i] = (real * real + imag * imag).sqrt() / bufferSize;
    }

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

  /// Stop listening to microphone input
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _audioSubscription?.cancel();
    _audioSubscription = null;
    _micStream = null;
    _audioBuffer.clear();
    _isListening = false;

    print('Audio input stopped');
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
