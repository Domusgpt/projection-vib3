# VIB3 Light Lab - Getting Started Guide

**How to begin implementation TODAY**

---

## 🎯 Quick Start: First Hour

### Step 1: Project Setup (10 minutes)

```bash
# Create new Flutter project (if not already created)
cd /mnt/c/Users/millz/
flutter create vib3_light_lab_v2
cd vib3_light_lab_v2

# OR use existing Vib3-Light-Lab directory
cd /mnt/c/Users/millz/Vib3-Light-Lab/vib3_light_lab
```

### Step 2: Add Dependencies (5 minutes)

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # WebGL Integration
  flutter_inappwebview: ^6.0.0

  # Math & Utilities
  vector_math: ^2.1.4

  # Audio (placeholder - research best option)
  # flutter_sound: ^9.x.x
  # OR fft: ^2.x.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

Run:
```bash
flutter pub get
```

### Step 3: Create Directory Structure (5 minutes)

```bash
mkdir -p lib/{models,providers,services,widgets/{bezel,floating,canvas,audio,timeline},utils}
mkdir -p lib/widgets/bezel/tabs
mkdir -p assets/webgl
```

**Result**:
```
lib/
├── main.dart
├── models/
│   ├── vib3_parameters.dart
│   ├── audio_band.dart
│   └── vj_configuration.dart
├── providers/
│   ├── engine_provider.dart
│   ├── config_provider.dart
│   └── audio_provider.dart
├── services/
│   ├── audio_analyzer.dart
│   ├── beat_detector.dart
│   └── camera_rail_system.dart
├── widgets/
│   ├── bezel/
│   │   ├── bezel_tab_bar.dart
│   │   └── tabs/
│   │       ├── rotation_tab.dart
│   │       ├── visual_tab.dart
│   │       └── ... (all 9 tabs)
│   ├── floating/
│   │   ├── pullable_control.dart
│   │   ├── configurable_xy_pad.dart
│   │   └── ...
│   ├── canvas/
│   │   └── interactive_webgl_canvas.dart
│   └── audio/
│       └── mapping_editor.dart
└── utils/
    ├── vib3_theme.dart
    └── vib3_colors.dart
```

### Step 4: Create Core Files (40 minutes)

**File 1: `lib/utils/vib3_colors.dart`** (5 min)

```dart
import 'package:flutter/material.dart';

class VIB3Colors {
  // Primary Colors
  static const cyan = Color(0xFF33C4FF);
  static const magenta = Color(0xFFFF33C4);
  static const purple = Color(0xFFC433FF);
  static const pink = Color(0xFFFF69B4);
  static const green = Color(0xFF33FF57);
  static const orange = Color(0xFFFF8C33);
  static const blue = Color(0xFF3357FF);

  // Background Colors
  static const darkNavy = Color(0xFF0A0E1A);
  static const darkPurple = Color(0xFF1A0E2E);
  static const deepPurple = Color(0xFF2E1A4A);

  // UI Elements
  static const glassBorder = Color(0x33FFFFFF);
  static const glassFill = Color(0x1AFFFFFF);

  // Gradients
  static const backgroundGradient = [
    darkNavy,
    darkPurple,
  ];
}
```

**File 2: `lib/models/vib3_parameters.dart`** (10 min)

```dart
enum VIB3Parameters {
  // 6 Rotation Planes
  rotationXY,
  rotationXZ,
  rotationYZ,
  rotationXW,
  rotationYW,
  rotationZW,

  // Visual Parameters
  gridDensity,
  morphFactor,
  chaos,
  speed,

  // Color Parameters
  hue,
  saturation,
  intensity,

  // Effects
  cardBend,
  cardBendAxis,
  perspectiveFOV,
  bloom,
  chromaticAberration,
  rgbShift,

  // Camera
  cameraX,
  cameraY,
  cameraZ,
  cameraFOV,
  cameraRailProgress,

  // Lighting
  keyLightIntensity,
  keyLightColor,
  fillLightIntensity,
  fillLightColor,
  backLightIntensity,
  backLightColor,
  ambientLightIntensity,
  ambientLightColor,

  // Advanced
  paletteOrbitPosition,
  paletteSwapTrigger,
  macro1,
  macro2,
  macro3,
  geometryCycleTrigger,
}

class Parameter {
  final VIB3Parameters key;
  final String displayName;
  final List<num> range;
  final num defaultValue;

  const Parameter({
    required this.key,
    required this.displayName,
    required this.range,
    required this.defaultValue,
  });
}

const allParameters = [
  Parameter(
    key: VIB3Parameters.rotationXY,
    displayName: '4D-XY Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.hue,
    displayName: 'Color Hue',
    range: [0, 360],
    defaultValue: 180,
  ),
  // ... (add all 44+ parameters)
];
```

**File 3: `lib/providers/engine_provider.dart`** (15 min)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vib3_parameters.dart';

class EngineState {
  final Map<VIB3Parameters, num> parameters;
  final String activeSystem; // 'faceted', 'quantum', 'holographic', 'polychora'
  final int activeGeometry; // 0-23

  EngineState({
    required this.parameters,
    this.activeSystem = 'faceted',
    this.activeGeometry = 0,
  });

  EngineState copyWith({
    Map<VIB3Parameters, num>? parameters,
    String? activeSystem,
    int? activeGeometry,
  }) {
    return EngineState(
      parameters: parameters ?? this.parameters,
      activeSystem: activeSystem ?? this.activeSystem,
      activeGeometry: activeGeometry ?? this.activeGeometry,
    );
  }
}

class EngineNotifier extends StateNotifier<EngineState> {
  EngineNotifier() : super(EngineState(parameters: _getDefaults()));

  static Map<VIB3Parameters, num> _getDefaults() {
    final defaults = <VIB3Parameters, num>{};
    for (final param in allParameters) {
      defaults[param.key] = param.defaultValue;
    }
    return defaults;
  }

  void setParameter(VIB3Parameters param, num value) {
    final newParams = Map<VIB3Parameters, num>.from(state.parameters);
    newParams[param] = value;
    state = state.copyWith(parameters: newParams);

    // TODO: Send to WebGL via JavaScript bridge
    _sendToWebGL(param, value);
  }

  void applyParameterBatch(Map<VIB3Parameters, num> batch) {
    final newParams = Map<VIB3Parameters, num>.from(state.parameters);
    newParams.addAll(batch);
    state = state.copyWith(parameters: newParams);

    // TODO: Send batch to WebGL
    _sendBatchToWebGL(batch);
  }

  void setActiveSystem(String system) {
    state = state.copyWith(activeSystem: system);
    // TODO: Send to WebGL
  }

  void randomizeAll() {
    final newParams = <VIB3Parameters, num>{};
    for (final param in allParameters) {
      final range = param.range;
      final random = (range[1] - range[0]) * (DateTime.now().millisecondsSinceEpoch % 100) / 100.0;
      newParams[param.key] = range[0] + random;
    }
    state = state.copyWith(parameters: newParams);
  }

  void resetAll() {
    state = EngineState(parameters: _getDefaults());
  }

  void _sendToWebGL(VIB3Parameters param, num value) {
    // TODO: Implement JavaScript bridge communication
    print('WebGL: ${param.name} = $value');
  }

  void _sendBatchToWebGL(Map<VIB3Parameters, num> batch) {
    // TODO: Implement batch update
    print('WebGL Batch: ${batch.length} parameters');
  }
}

final engineProvider = StateNotifierProvider<EngineNotifier, EngineState>((ref) {
  return EngineNotifier();
});
```

**File 4: `lib/main.dart`** (10 min)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/vib3_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: VIB3Colors.darkNavy,
    ),
  );

  runApp(
    const ProviderScope(
      child: VIB3LightLabApp(),
    ),
  );
}

class VIB3LightLabApp extends StatelessWidget {
  const VIB3LightLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIB3 Light Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: VIB3Colors.darkNavy,
        primaryColor: VIB3Colors.cyan,
        colorScheme: ColorScheme.dark(
          primary: VIB3Colors.cyan,
          secondary: VIB3Colors.magenta,
          surface: VIB3Colors.darkPurple,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VIB3 LIGHT LAB',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: VIB3Colors.cyan,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Professional VJ Controller',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Ready to build! 🚀',
                  style: TextStyle(
                    fontSize: 20,
                    color: VIB3Colors.magenta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## ✅ Test Your Setup

Run the app:

```bash
flutter run
```

**Expected Result**:
- Dark gradient background (navy → purple)
- "VIB3 LIGHT LAB" title in cyan
- "Ready to build! 🚀" in magenta

---

## 🎯 Next Steps (Day 1)

### Hour 2: Build First Bezel Tab

**Goal**: Create a working bezel tab system with one tab (4D Rotation)

1. Create `lib/widgets/bezel/bezel_tab_bar.dart`
2. Create `lib/widgets/bezel/tabs/rotation_tab.dart`
3. Add XY pad widget (basic touch detection)
4. Connect to EngineProvider
5. Test parameter updates

### Hour 3-4: Add WebGL View

**Goal**: Display vib3-plus-engine in the app

1. Copy vib3-plus-engine to `assets/webgl/`
2. Create `lib/widgets/canvas/webgl_view.dart`
3. Set up InAppWebView with transparent background
4. Test WebGL rendering

### Hour 5-6: Connect Parameters to WebGL

**Goal**: Control visualization from Flutter

1. Set up JavaScript bridge
2. Implement `window.flutter_inappwebview` handlers
3. Test `setParameter()` calls from Flutter → WebGL
4. Verify rotation changes in visualization

---

## 📝 Pro Tips

**Debugging**:
```bash
# Hot reload during development
# Press 'r' in terminal while app is running

# Full restart
# Press 'R' in terminal

# Open DevTools
flutter run --dart-define=FLUTTER_WEB_USE_SKIA=true
# Then press 'p' for Performance Overlay
```

**Common Issues**:

1. **WebGL not loading**:
   - Check `assets/webgl/` path in pubspec.yaml
   - Verify InAppWebView permissions (Android manifest)

2. **State not updating**:
   - Make sure you're using `ref.read()` for mutations
   - Use `ref.watch()` for listening to changes

3. **Performance issues**:
   - Enable `--profile` mode for accurate FPS
   - Use `PerformanceOverlay` to monitor

---

## 🌟 You're Ready!

Follow this guide, and in **6 hours** you'll have:
- ✅ Project structure
- ✅ Core state management
- ✅ First bezel tab with XY pad
- ✅ WebGL visualization rendering
- ✅ Flutter ↔ WebGL communication

**Then you can move to Phase 2** and build the remaining 8 bezel tabs!

---

**A Paul Phillips Manifestation**
