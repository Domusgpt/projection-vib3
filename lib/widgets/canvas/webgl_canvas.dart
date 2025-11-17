import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/engine_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/webgl_bridge.dart';
import '../../utils/logger.dart';
import '../../utils/vib3_colors.dart';

/// WebGL Canvas Widget with InAppWebView integration and proper lifecycle management
class WebGLCanvas extends ConsumerStatefulWidget {
  const WebGLCanvas({super.key});

  @override
  ConsumerState<WebGLCanvas> createState() => _WebGLCanvasState();
}

class _WebGLCanvasState extends ConsumerState<WebGLCanvas> {
  InAppWebViewController? _webViewController;
  WebGLBridge? _bridge;
  bool _engineReady = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isLoading = true;
  Timer? _updateTimer;

  // Track last sent values to avoid unnecessary updates
  Map<String, dynamic>? _lastSentParameters;
  Map<String, double>? _lastSentAudioBands;

  @override
  void initState() {
    super.initState();
    _startUpdateLoop();
  }

  void _startUpdateLoop() {
    // Send updates at 30 FPS (lower than render loop to reduce overhead)
    _updateTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (_engineReady && _bridge != null && mounted) {
        _sendParameterUpdates();
      }
    });
  }

  void _sendParameterUpdates() {
    final engineState = ref.read(engineProvider);
    final audioState = ref.read(audioProvider);

    // Only send if parameters have changed
    final currentParams = Map<String, dynamic>.from(
      engineState.parameters.map((key, value) => MapEntry(key.name, value))
    );

    if (_lastSentParameters == null ||
        _areMapsDifferent(currentParams, _lastSentParameters!)) {
      _bridge!.updateAllParameters(engineState.parameters);
      _lastSentParameters = currentParams;
    }

    // Send audio bands
    final audioBands = {
      'sub': audioState.analyzer.subLevel,
      'bass': audioState.analyzer.bassLevel,
      'lowMid': audioState.analyzer.lowMidLevel,
      'mid': audioState.analyzer.midLevel,
      'highMid': audioState.analyzer.highMidLevel,
      'presence': audioState.analyzer.presenceLevel,
      'air': audioState.analyzer.airLevel,
    };

    if (_lastSentAudioBands == null ||
        _areAudioBandsDifferent(audioBands, _lastSentAudioBands!)) {
      _bridge!.updateAudioBands(
        audioState.analyzer.subLevel,
        audioState.analyzer.bassLevel,
        audioState.analyzer.lowMidLevel,
        audioState.analyzer.midLevel,
        audioState.analyzer.highMidLevel,
        audioState.analyzer.presenceLevel,
        audioState.analyzer.airLevel,
      );
      _lastSentAudioBands = audioBands;
    }
  }

  bool _areMapsDifferent(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return true;
    for (final key in a.keys) {
      if (a[key] != b[key]) return true;
    }
    return false;
  }

  bool _areAudioBandsDifferent(Map<String, double> a, Map<String, double> b) {
    const threshold = 0.001; // Only update if change is significant
    for (final key in a.keys) {
      if ((a[key]! - (b[key] ?? 0.0)).abs() > threshold) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while WebGL initializes
    if (_isLoading && !_engineReady && !_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: VIB3Colors.cyan,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Initializing WebGL Engine...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Show error state if WebGL failed to load
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: VIB3Colors.orange,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'WebGL Engine Error',
              style: TextStyle(
                color: VIB3Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to initialize',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VIB3Colors.cyan,
                foregroundColor: Colors.black,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show WebGL canvas with fade-in animation
    return AnimatedOpacity(
      opacity: _engineReady ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: InAppWebView(
      key: const ValueKey('webgl_canvas'), // Prevent recreation
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        disableContextMenu: true,
        supportZoom: false,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        hardwareAcceleration: true,
        cacheEnabled: false, // Disable cache for hot reload during dev
      ),
      initialFile: 'assets/webgl/index.html',
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _bridge = WebGLBridge(controller);

        // Register JavaScript handlers
        controller.addJavaScriptHandler(
          handlerName: 'engineReady',
          callback: (args) {
            if (mounted) {
              setState(() {
                _engineReady = true;
                _isLoading = false;
                _hasError = false;
              });
              VIB3Logger.success('VIB3 WebGL Engine ready', 'WebGL');
            }
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'touchCount',
          callback: (args) {
            if (args.isNotEmpty && mounted) {
              final count = args[0] as int;
              VIB3Logger.debug('Touch count: $count', 'WebGL');
            }
          },
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        VIB3Logger.debug(consoleMessage.message, 'WebGL Console');
      },
      onLoadStop: (controller, url) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        VIB3Logger.success('WebGL page loaded: $url', 'WebGL');
      },
      onReceivedError: (controller, request, error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = error.description;
          });
        }
        VIB3Logger.error('WebGL load error: ${error.description}', 'WebGL');
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'HTTP ${errorResponse.statusCode}';
          });
        }
        VIB3Logger.error('WebGL HTTP error ${errorResponse.statusCode}', 'WebGL');
      },
      ),
    );
  }

  @override
  void dispose() {
    VIB3Logger.info('Disposing WebGL Canvas', 'WebGL');
    _updateTimer?.cancel();
    _updateTimer = null;

    // Clean up WebView
    _webViewController?.dispose();
    _webViewController = null;
    _bridge = null;
    _engineReady = false;
    _lastSentParameters = null;
    _lastSentAudioBands = null;

    super.dispose();
  }
}
