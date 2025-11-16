import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/engine_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/webgl_bridge.dart';

/// WebGL Canvas Widget with InAppWebView integration
class WebGLCanvas extends ConsumerStatefulWidget {
  const WebGLCanvas({super.key});

  @override
  ConsumerState<WebGLCanvas> createState() => _WebGLCanvasState();
}

class _WebGLCanvasState extends ConsumerState<WebGLCanvas> {
  InAppWebViewController? _webViewController;
  WebGLBridge? _bridge;
  bool _engineReady = false;

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(engineProvider);
    final audioState = ref.watch(audioProvider);

    // Update parameters when engine is ready and state changes
    if (_engineReady && _bridge != null) {
      _bridge!.updateAllParameters(engineState.parameters);
      _bridge!.updateAudioBands(
        audioState.analyzer.subLevel,
        audioState.analyzer.bassLevel,
        audioState.analyzer.lowMidLevel,
        audioState.analyzer.midLevel,
        audioState.analyzer.highMidLevel,
        audioState.analyzer.presenceLevel,
        audioState.analyzer.airLevel,
      );
    }

    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        disableContextMenu: true,
        supportZoom: false,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        hardwareAcceleration: true,
      ),
      initialFile: 'assets/webgl/index.html',
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _bridge = WebGLBridge(controller);

        // Register JavaScript handlers
        controller.addJavaScriptHandler(
          handlerName: 'engineReady',
          callback: (args) {
            setState(() {
              _engineReady = true;
            });
            print('VIB3 WebGL Engine ready');
          },
        );

        controller.addJavaScriptHandler(
          handlerName: 'touchCount',
          callback: (args) {
            if (args.isNotEmpty) {
              final count = args[0] as int;
              // This will be picked up by the MultiTouchFeedback overlay
              print('Touch count: $count');
            }
          },
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        print('WebGL Console: ${consoleMessage.message}');
      },
      onLoadStop: (controller, url) {
        print('WebGL page loaded: $url');
      },
      onLoadError: (controller, url, code, message) {
        print('WebGL load error: $message');
      },
    );
  }

  @override
  void dispose() {
    _bridge = null;
    _webViewController = null;
    super.dispose();
  }
}
