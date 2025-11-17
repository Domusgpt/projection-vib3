import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/engine_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/webgl_bridge.dart';
import '../../utils/logger.dart';

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
    // Don't call parameter updates in build - using Timer instead
    return InAppWebView(
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
        VIB3Logger.success('WebGL page loaded: $url', 'WebGL');
      },
      onReceivedError: (controller, request, error) {
        VIB3Logger.error('WebGL load error: ${error.description}', 'WebGL');
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        VIB3Logger.error('WebGL HTTP error ${errorResponse.statusCode}', 'WebGL');
      },
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
