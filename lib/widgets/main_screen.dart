import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/vib3_colors.dart';
import '../utils/vib3_theme.dart';
import '../widgets/bezel/bezel_tab_bar.dart';
import '../widgets/canvas/webgl_canvas.dart';
import '../widgets/canvas/multi_touch_feedback.dart';
import '../widgets/floating/floating_widgets_overlay.dart';
import '../providers/audio_provider.dart';
import '../providers/palette_provider.dart';
import '../providers/camera_provider.dart';
import '../providers/lighting_provider.dart';
import '../providers/macro_provider.dart';
import '../providers/timeline_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  int _fingerCount = 0;
  VIB3ControlCategory? _expandedTab;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Start update loops for all providers
    _startUpdateLoops();
  }

  void _startUpdateLoops() {
    // Update at 60 FPS using Timer.periodic (properly cancellable)
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;

      // Update camera
      ref.read(cameraProvider.notifier).update(0.016);

      // Update palette orbit
      ref.read(paletteProvider.notifier).update(0.016);

      // Update lighting (audio-reactive)
      ref.read(lightingProvider.notifier).update();

      // Update macros (audio-reactive)
      ref.read(macroProvider.notifier).update();
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final canvasHeight = _expandedTab != null
        ? screenHeight * 0.7
        : screenHeight - 50 - 50; // minus top bar and bezel

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: VIB3Colors.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar (minimal)
              _buildTopBar(context, audioState),

              // WebGL Canvas with multi-touch feedback
              SizedBox(
                height: canvasHeight,
                child: Stack(
                  children: [
                    // WebGL Canvas
                    WebGLCanvas(),

                    // Multi-touch border feedback
                    MultiTouchFeedback(fingerCount: _fingerCount),

                    // Floating widgets overlay
                    FloatingWidgetsOverlay(),
                  ],
                ),
              ),

              // Bezel Tab Bar
              BezelTabBar(
                expandedTab: _expandedTab,
                onTabTapped: (category) {
                  setState(() {
                    if (_expandedTab == category) {
                      _expandedTab = null; // Collapse
                    } else {
                      _expandedTab = category; // Expand
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AudioState audioState) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // System selector icons
          _systemIcon(Icons.filter_4, VIB3Colors.cyan),
          SizedBox(width: 8),
          _systemIcon(Icons.scatter_plot, VIB3Colors.magenta),
          SizedBox(width: 8),
          _systemIcon(Icons.bubble_chart, VIB3Colors.purple),
          SizedBox(width: 8),
          _systemIcon(Icons.view_in_ar, VIB3Colors.pink),

          Spacer(),

          // BPM Display
          GlassmorphicContainer(
            width: 100,
            height: 30,
            opacity: 0.3,
            blur: 6,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 14, color: VIB3Colors.green),
                SizedBox(width: 4),
                Text(
                  'BPM: ${audioState.beatEngine.bpm.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

          Spacer(),

          // Microphone toggle
          IconButton(
            icon: Icon(
              audioState.isAudioActive ? Icons.mic : Icons.mic_off,
              size: 20,
              color: audioState.isAudioActive ? VIB3Colors.green : Colors.white.withOpacity(0.5),
            ),
            onPressed: () {
              ref.read(audioProvider.notifier).toggleAudioActive();
            },
          ),

          // Gallery and Config buttons
          IconButton(
            icon: Icon(Icons.photo_library, size: 20, color: VIB3Colors.cyan),
            onPressed: () {
              // TODO: Open gallery
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 20, color: VIB3Colors.magenta),
            onPressed: () {
              // TODO: Open config
            },
          ),
        ],
      ),
    );
  }

  Widget _systemIcon(IconData icon, Color color) {
    return GlassmorphicContainer(
      width: 32,
      height: 32,
      opacity: 0.3,
      blur: 6,
      borderColor: color.withOpacity(0.5),
      padding: EdgeInsets.all(4),
      child: Icon(icon, size: 20, color: color),
    );
  }

  @override
  void dispose() {
    print('🧹 Disposing MainScreen - cancelling update timer');
    _updateTimer?.cancel();
    _updateTimer = null;
    super.dispose();
  }
}
