import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vib3_parameters.dart';
import '../../providers/engine_provider.dart';

class WebGLCanvas extends ConsumerStatefulWidget {
  const WebGLCanvas({super.key});

  @override
  ConsumerState<WebGLCanvas> createState() => _WebGLCanvasState();
}

class _WebGLCanvasState extends ConsumerState<WebGLCanvas> {
  InAppWebViewController? _webViewController;
  bool _isWebGLReady = false;

  @override
  Widget build(BuildContext context) {
    // Listen to engine state changes
    ref.listen<EngineState>(engineProvider, (previous, next) {
      if (_isWebGLReady && previous != null) {
        _sendParameterUpdates(previous, next);
      }
    });

    return Stack(
      children: [
        InAppWebView(
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: false,
            disableContextMenu: true,
            allowsInlineMediaPlayback: true,
            mediaPlaybackRequiresUserGesture: false,
            useWideViewPort: false,
          ),
          initialData: InAppWebViewInitialData(
            data: _getTestHTML(),
            baseUrl: WebUri('http://localhost/'),
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;

            // Add JavaScript handler for WebGL readiness
            controller.addJavaScriptHandler(
              handlerName: 'webglReady',
              callback: (args) {
                setState(() {
                  _isWebGLReady = true;
                });
                print('✅ WebGL engine ready');

                // Send initial parameters
                _sendAllParameters();
              },
            );

            // Add JavaScript handler for WebGL errors
            controller.addJavaScriptHandler(
              handlerName: 'webglError',
              callback: (args) {
                print('❌ WebGL error: ${args.isNotEmpty ? args[0] : "Unknown"}');
              },
            );
          },
          onConsoleMessage: (controller, consoleMessage) {
            print('WebGL Console: ${consoleMessage.message}');
          },
          onLoadStop: (controller, url) {
            print('✅ WebGL view loaded: $url');
          },
        ),
        // Loading indicator
        if (!_isWebGLReady)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.cyan,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Initializing WebGL Engine...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _sendParameterUpdates(EngineState previous, EngineState next) {
    if (_webViewController == null) return;

    // Collect changed parameters
    final changes = <String, dynamic>{};

    next.parameters.forEach((key, value) {
      if (previous.parameters[key] != value) {
        changes[key.name] = value;
      }
    });

    if (changes.isNotEmpty) {
      _webViewController!.evaluateJavascript(source: '''
        if (window.vib3Engine && window.vib3Engine.setParameters) {
          window.vib3Engine.setParameters(${_toJSON(changes)});
        }
      ''');
    }

    // Check for system/geometry changes
    if (previous.activeSystem != next.activeSystem) {
      _webViewController!.evaluateJavascript(source: '''
        if (window.vib3Engine && window.vib3Engine.setActiveSystem) {
          window.vib3Engine.setActiveSystem('${next.activeSystem}');
        }
      ''');
    }

    if (previous.activeGeometry != next.activeGeometry) {
      _webViewController!.evaluateJavascript(source: '''
        if (window.vib3Engine && window.vib3Engine.setActiveGeometry) {
          window.vib3Engine.setActiveGeometry(${next.activeGeometry});
        }
      ''');
    }
  }

  void _sendAllParameters() {
    if (_webViewController == null) return;

    final engineState = ref.read(engineProvider);
    final params = <String, dynamic>{};

    engineState.parameters.forEach((key, value) {
      params[key.name] = value;
    });

    _webViewController!.evaluateJavascript(source: '''
      if (window.vib3Engine && window.vib3Engine.setParameters) {
        window.vib3Engine.setParameters(${_toJSON(params)});
        console.log('📦 Sent ${params.length} parameters to WebGL');
      }
    ''');
  }

  String _toJSON(Map<String, dynamic> map) {
    final entries = map.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : e.value;
      return '"${e.key}": $value';
    }).join(', ');
    return '{$entries}';
  }

  String _getTestHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      width: 100vw;
      height: 100vh;
      overflow: hidden;
      background: linear-gradient(135deg, #0A0E1A 0%, #1A0E2E 100%);
      font-family: 'Courier New', monospace;
    }

    #canvas {
      width: 100%;
      height: 100%;
      display: block;
    }

    #debug-overlay {
      position: absolute;
      top: 10px;
      left: 10px;
      background: rgba(0, 0, 0, 0.7);
      color: #33C4FF;
      padding: 10px;
      border-radius: 5px;
      font-size: 12px;
      max-width: 300px;
      pointer-events: none;
      font-family: 'Courier New', monospace;
    }

    .param-update {
      color: #FF33C4;
      margin: 2px 0;
    }
  </style>
</head>
<body>
  <canvas id="canvas"></canvas>
  <div id="debug-overlay">
    <div>🌟 VIB3 WebGL Engine Test</div>
    <div id="status">Status: Initializing...</div>
    <div id="params-count">Parameters: 0</div>
    <div id="last-update"></div>
  </div>

  <script>
    // Simple test WebGL context
    const canvas = document.getElementById('canvas');
    const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

    if (!gl) {
      document.getElementById('status').textContent = '❌ WebGL not supported';
      window.flutter_inappwebview.callHandler('webglError', 'WebGL not supported');
    } else {
      // Resize canvas
      function resize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        gl.viewport(0, 0, canvas.width, canvas.height);
      }
      resize();
      window.addEventListener('resize', resize);

      // Create VIB3 engine mock
      window.vib3Engine = {
        parameters: {},
        activeSystem: 'faceted',
        activeGeometry: 0,

        setParameters: function(params) {
          Object.assign(this.parameters, params);
          const count = Object.keys(this.parameters).length;
          document.getElementById('params-count').textContent = 'Parameters: ' + count;

          // Show last 3 updates
          const updates = Object.entries(params).slice(0, 3).map(([k, v]) =>
            \`<div class="param-update">\${k}: \${typeof v === 'number' ? v.toFixed(2) : v}</div>\`
          ).join('');
          document.getElementById('last-update').innerHTML = updates;

          // Update visualization
          render();
        },

        setActiveSystem: function(system) {
          this.activeSystem = system;
          console.log('🔷 Active system:', system);
        },

        setActiveGeometry: function(geometry) {
          this.activeGeometry = geometry;
          console.log('🔷 Active geometry:', geometry);
        }
      };

      // Render function
      let hue = 0;
      function render() {
        const params = window.vib3Engine.parameters;

        // Use rotation parameters to change colors
        const rotXY = params.rotationXY || 0;
        const rotXZ = params.rotationXZ || 0;
        const rotYZ = params.rotationYZ || 0;

        // Map rotations to colors
        const r = Math.sin(rotXY) * 0.5 + 0.5;
        const g = Math.sin(rotXZ) * 0.5 + 0.5;
        const b = Math.sin(rotYZ) * 0.5 + 0.5;

        gl.clearColor(r * 0.3, g * 0.3, b * 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // Simple rotating gradient effect
        hue += 0.5;
      }

      // Animation loop
      function animate() {
        render();
        requestAnimationFrame(animate);
      }
      animate();

      // Notify Flutter that WebGL is ready
      document.getElementById('status').textContent = '✅ WebGL Ready';
      window.flutter_inappwebview.callHandler('webglReady');
    }
  </script>
</body>
</html>
    ''';
  }
}
