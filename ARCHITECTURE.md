# VIB3 Light Lab - Architecture Documentation

**A Paul Phillips Manifestation**
**Professional VJ System with Hybrid Bezel + Floating Controls**

---

## 🎯 System Overview

This is a comprehensive Flutter-based VJ controller application featuring:

- **Hybrid Control System**: Controls can be collapsed in bezel tabs or pulled out as floating widgets
- **9 Bezel Tab Categories**: 4D Rotation, Visual, Color, Audio, Effects, Timeline, Camera, Lighting, Macros
- **Multi-touch Canvas Control**: Direct manipulation of 4D rotations with visual feedback
- **Advanced Audio Reactivity**: 7-band FFT analysis with customizable parameter mappings
- **Camera Rail System**: Cinematic camera movements with beat synchronization
- **Color Palette Orbit**: Lab color space blending for smooth color transitions
- **Timeline Sequencer**: Keyframe animation and beat-synced automation
- **3-Point Lighting**: Professional lighting system with audio reactivity
- **Macro Controls**: High-level control abstractions affecting multiple parameters

---

## 📁 Project Structure

```
lib/
├── main.dart                       # App entry point
├── models/                         # Data models
│   ├── vib3_parameters.dart       # All 44+ controllable parameters
│   ├── audio_band.dart            # 7-band audio analysis models
│   ├── camera_system.dart         # Camera rail and keyframe models
│   ├── color_palette.dart         # Palette system with Lab blending
│   ├── macro_control.dart         # Macro mapping models
│   ├── timeline.dart              # Timeline and automation models
│   └── lighting_system.dart       # 3-point lighting models
├── providers/                      # Riverpod state management
│   ├── engine_provider.dart       # Main engine state
│   ├── audio_provider.dart        # Audio analysis and beat detection
│   ├── palette_provider.dart      # Color palette orbit system
│   ├── timeline_provider.dart     # Timeline playback
│   ├── camera_provider.dart       # Camera rail management
│   ├── lighting_provider.dart     # Lighting system
│   └── macro_provider.dart        # Macro control system
├── services/                       # Business logic services
│   ├── audio_analyzer.dart        # 7-band FFT analyzer
│   ├── beat_detector.dart         # BPM detection and tracking
│   └── camera_rail_system.dart    # Camera animation system
├── utils/                          # Utilities and theme
│   ├── vib3_colors.dart          # Color palette
│   └── vib3_theme.dart           # Theme and glassmorphic widgets
└── widgets/                        # UI components
    ├── main_screen.dart           # Main application screen
    ├── bezel/                     # Bezel tab system
    │   ├── bezel_tab_bar.dart    # Tab bar with expand/collapse
    │   └── tabs/                  # Individual tab implementations
    │       ├── rotation_tab.dart  # 6 rotation plane controls
    │       ├── visual_tab.dart    # Visual parameter controls
    │       ├── color_tab.dart     # Color controls
    │       ├── audio_tab.dart     # Audio reactivity config
    │       ├── effects_tab.dart   # Card bend, bloom, etc.
    │       ├── timeline_tab.dart  # Timeline sequencer
    │       ├── camera_tab.dart    # Camera rail controls
    │       ├── lighting_tab.dart  # Lighting controls
    │       └── macros_tab.dart    # Macro controls
    └── canvas/                     # Canvas and visualization
        ├── webgl_canvas.dart      # WebGL integration (TODO)
        └── multi_touch_feedback.dart  # Border glow feedback
```

---

## 🏗️ Core Architecture

### 1. **State Management (Riverpod)**

All application state is managed through Riverpod providers:

- `engineProvider`: Main VIB3 engine parameters
- `audioProvider`: Audio analysis, beat detection, BPM tracking
- `paletteProvider`: Color palette orbit and swapping
- `timelineProvider`: Timeline playback and automation
- `cameraProvider`: Camera position and rail animation
- `lightingProvider`: 3-point lighting system
- `macroProvider`: Macro controls and mappings

### 2. **Parameter System**

44+ parameters defined in `VIB3Parameters` enum:

**Rotation (6 planes)**:
- XY, XZ, YZ, XW, YW, ZW

**Visual (4)**:
- Grid Density, Morph Factor, Chaos, Speed

**Color (3)**:
- Hue, Saturation, Intensity

**Effects (6)**:
- Card Bend, Card Bend Axis, Perspective FOV, Bloom, Chromatic Aberration, RGB Shift

**Camera (5)**:
- Camera X/Y/Z, Camera FOV, Camera Rail Progress

**Lighting (8)**:
- Key/Fill/Back/Ambient Light Intensity and Color

**Advanced (12)**:
- Palette Orbit, Palette Swap Trigger, Macros 1-3, Geometry Cycle, etc.

### 3. **Audio Reactivity System**

**7-Band FFT Analysis**:
```dart
- Sub (20-60 Hz)
- Bass (60-250 Hz)
- Low Mid (250-1000 Hz)
- Mid (1000-4000 Hz)
- High Mid (4000-8000 Hz)
- Presence (8000-16000 Hz)
- Air (16000-20000 Hz)
```

**Audio Sources Available for Mapping**:
- All 7 frequency bands
- Overall volume (RMS)
- Beat trigger (kick detection)
- Downbeat trigger (measure start)
- Measure progress (0.0-1.0)
- BPM-synced LFO (sine/saw/square waves)

**Mapping Modes**:
- Direct: Audio value directly controls parameter
- Inverted: 1.0 - audioValue
- Smoothed: Exponential moving average
- Triggered: Jump to value on beat, decay over time
- Gated: Only active when audio exceeds threshold

### 4. **Camera Rail System**

**Features**:
- Predefined cinematic rails (Circular, Zoom, Figure-8)
- Custom keyframe-based paths
- Beat synchronization
- Audio-reactive camera distance
- Multiple easing modes (Linear, EaseIn, EaseOut, Bounce)
- Loop modes (Once, Loop, PingPong)

**Path Types**:
- Linear: Straight interpolation between keyframes
- Circular: Orbital path around origin
- Bezier: Smooth curved paths
- Figure-8: Lissajous curve motion

### 5. **Color Palette System**

**Lab Color Space Blending**:
- Perceptually uniform color interpolation
- Smooth transitions between palette colors
- Audio-triggered palette swaps
- Multiple orbit modes (Circular, PingPong, Random Walk, Beat-Triggered)

**8 Preset Palettes**:
- Sunset Vibes, Ocean Depths, Neon Nights, Forest
- Cyberpunk, Pastel Dreams, Fire & Ice, Monochrome

### 6. **Macro Control System**

High-level controls that affect multiple parameters simultaneously:

**Example: "Intensity Sweep" Macro**
```dart
MacroControl(
  name: 'Intensity Sweep',
  parameterMappings: {
    'intensity': MacroMapping(scale: 1.0, offset: 0.0, power: 1.0),
    'saturation': MacroMapping(scale: 0.8, offset: 0.2, power: 1.0),
    'speed': MacroMapping(scale: 2.0, offset: 0.5, power: 1.5),
    'gridDensity': MacroMapping(scale: 100, offset: 0, power: 1.0),
  },
  audioReactive: AudioReactivityConfig(
    source: AudioSource.overallVolume,
    intensity: 0.4,
  ),
)
```

### 7. **Timeline Sequencer**

**Track Types**:
- Parameter Automation: Keyframe-based parameter control
- Beat Trigger: Trigger events on specific beats
- Geometry Change: Switch geometries on timeline
- Palette Swap: Change color palettes automatically

**Features**:
- 60 FPS playback
- BPM-synced timeline
- Loop mode
- Real-time parameter updates
- Preset sequences (Intro, Build, Drop, Breakdown)

---

## 🎨 UI/UX Design

### Bezel Tab System

**Collapsed State** (50px height):
- 9 tabs with icons and labels
- Minimal screen footprint
- Quick access to all categories

**Expanded State** (30% screen height):
- Translucent glassmorphic panel (75% opacity, 8px blur)
- Full controls for selected category
- Color-coded borders matching category
- Collapse button at bottom

### Glassmorphic Design Language

**Visual States**:
- Bezel Tab (Collapsed): 70% opacity, 6px blur
- Bezel Tab (Expanded): 75% opacity, 8px blur
- Floating Widget (Inactive): 65% opacity, 10px blur
- Floating Widget (Active): 80% opacity, 12px blur

**Color Coding by Category**:
- Rotation: Cyan
- Visual: Magenta
- Color: Purple
- Audio: Green
- Effects: Orange
- Timeline: Blue
- Camera: Pink
- Lighting: Gold
- Macros: Dark Turquoise

### Multi-Touch Canvas Feedback

**Border Glow Color by Finger Count**:
- 1 finger: Purple (XW + YW rotation)
- 2 fingers: Cyan (XY + ZW rotation)
- 3 fingers: Magenta (XZ + YZ rotation)
- 4+ fingers: Rainbow gradient (All 6 planes)

**Small Badge Indicator**:
```
┌──────┐
│ 👆👆  │  ← Finger count + color-coded
│ XY+ZW│  ← Active planes label
└──────┘
```

---

## 🚀 Implementation Status

### ✅ Completed

1. **Core Architecture**
   - [x] Complete parameter system (44+ parameters)
   - [x] Riverpod state management setup
   - [x] All 6 providers (Engine, Audio, Palette, Timeline, Camera, Lighting, Macro)

2. **Models & Services**
   - [x] 7-band audio analyzer
   - [x] Beat detection engine with BPM tracking
   - [x] Camera rail system with keyframe interpolation
   - [x] Color palette system with Lab blending
   - [x] Macro control system
   - [x] Timeline sequencer models
   - [x] 3-point lighting system

3. **UI Components**
   - [x] Main screen layout
   - [x] Bezel tab bar with expand/collapse
   - [x] Glassmorphic container widget
   - [x] Multi-touch border feedback
   - [x] Rotation tab (6 rotation plane controls)
   - [x] Visual tab (4 parameter sliders)
   - [x] Placeholder tabs for remaining categories

### 🚧 To-Do

1. **Floating Widget System**
   - [ ] Pull-out mechanism for controls
   - [ ] Draggable floating widgets
   - [ ] Snap-to-edge behavior
   - [ ] Widget minimize/maximize

2. **WebGL Integration**
   - [ ] Integrate flutter_inappwebview
   - [ ] Load vib3-plus-engine
   - [ ] JavaScript bridge for parameter updates
   - [ ] Real-time rendering

3. **Advanced Tab Widgets**
   - [ ] Complete Color tab with HSI controls
   - [ ] Complete Audio tab with mapping editor
   - [ ] Complete Effects tab with card bend controls
   - [ ] Complete Timeline tab with sequencer UI
   - [ ] Complete Camera tab with rail editor
   - [ ] Complete Lighting tab with 3-point controls
   - [ ] Complete Macros tab with macro editor

4. **Audio Implementation**
   - [ ] Choose and integrate audio library (flutter_sound or similar)
   - [ ] Real-time FFT analysis
   - [ ] Audio input from microphone or system audio

5. **Persistence**
   - [ ] Hive integration for saving presets
   - [ ] Export/import configurations
   - [ ] Preset management UI

---

## 🎯 Next Steps for Development

1. **Immediate**: Complete all tab widget implementations
2. **Short-term**: Implement floating widget system
3. **Medium-term**: WebGL integration with vib3-plus-engine
4. **Long-term**: Audio analysis implementation

---

## 📚 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  hive: ^2.2.3                  # Local storage
  hive_flutter: ^1.1.0
  flutter_inappwebview: ^6.0.0  # WebGL integration
  vector_math: ^2.1.4           # Math utilities for 3D/4D
```

---

## 💡 Design Patterns Used

1. **Provider Pattern**: Riverpod for reactive state management
2. **Repository Pattern**: Services layer for business logic
3. **Observer Pattern**: Audio and timeline update loops
4. **Strategy Pattern**: Multiple audio mapping modes
5. **Factory Pattern**: Preset creation (palettes, macros, lighting)
6. **Composite Pattern**: Macro controls affecting multiple parameters

---

## 🎨 Color Palette

```dart
static const cyan = Color(0xFF33C4FF);
static const magenta = Color(0xFFFF33C4);
static const purple = Color(0xFFC433FF);
static const pink = Color(0xFFFF69B4);
static const green = Color(0xFF33FF57);
static const orange = Color(0xFFFF8C33);
static const blue = Color(0xFF3357FF);
static const darkNavy = Color(0xFF0A0E1A);
static const darkPurple = Color(0xFF1A0E2E);
```

---

## 🔧 Development Tips

1. **Hot Reload**: Use `r` in terminal for instant UI updates
2. **DevTools**: Press `p` for performance overlay
3. **State Inspection**: Use Riverpod DevTools extension
4. **Performance**: Monitor FPS in update loops (60 FPS target)

---

**Built with Flutter • Powered by Mathematics • Inspired by Beauty**

*A Paul Phillips Production*
