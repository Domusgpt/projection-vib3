# VIB3 Light Lab

**Professional VJ Controller for 4D Visualizations**

A revolutionary Flutter-based VJ performance controller integrating vib3-plus-engine for live 4D geometric visualization control with professional audio reactivity, timeline sequencing, and adaptive UI customization.

---

## 🎯 Project Status

**Phase 1: Core Infrastructure** ✅ COMPLETE
- Flutter project initialized with multi-platform support
- Core state management with Riverpod
- 44+ parameter definitions
- VIB3 branding and color system
- Complete documentation suite (172KB)

**Next: Phase 2** - Build first bezel tab (4D Rotation) with XY pad

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/Domusgpt/projection-vib3.git
cd projection-vib3

# Install dependencies
flutter pub get

# Run app
flutter run
```

**Expected Result**: Dark gradient background with "VIB3 LIGHT LAB" cyan title

---

## 📚 Documentation

Complete documentation located in `/docs`:

- **[00-README.md](docs/00-README.md)** - Master overview & roadmap
- **[01-MASTER-SPEC.md](docs/01-MASTER-SPEC.md)** - Complete system specification (66KB)
- **[02-LAYOUT-PATTERNS.md](docs/02-LAYOUT-PATTERNS.md)** - 4 visualization-first layout options
- **[03-VJ-RESEARCH.md](docs/03-VJ-RESEARCH.md)** - Professional VJ software analysis
- **[04-IMPLEMENTATION-CHECKLIST.md](docs/04-IMPLEMENTATION-CHECKLIST.md)** - 150+ task breakdown
- **[05-GETTING-STARTED.md](docs/05-GETTING-STARTED.md)** - First-day implementation guide

---

## 🏗️ Architecture

### Core Features

**Hybrid Control System**:
- 9 bezel tabs (4D Rotation, Visual, Color, Audio, Effects, Timeline, Camera, Lighting, Macros)
- Pullable floating controls (XY pads, knobs, faders)
- Adaptive parameter mapping via dropdown menus

**Audio Reactivity**:
- 7-band FFT analyzer (Sub, Bass, Low Mid, Mid, High Mid, Presence, Air)
- Beat/measure detection with BPM tracking
- User-configurable audio→parameter mappings

**Choreography Engine**:
- Camera rails with cinematic path interpolation
- Macro controls (multi-parameter abstractions)
- Palette orbit with Lab color blending
- 3-point lighting system
- Beat-synced geometry cycling

**Multi-Touch Canvas**:
- 6 degrees of 4D rotation control
- Finger count → rotation plane mapping
- Visual feedback via border color changes

### Tech Stack

- **Framework**: Flutter 3.9+
- **State Management**: Riverpod
- **Storage**: Hive (local configuration persistence)
- **WebGL**: InAppWebView + vib3-plus-engine
- **Math**: vector_math (4D geometry)

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with VIB3 branding
├── models/
│   └── vib3_parameters.dart     # 44+ parameter definitions
├── providers/
│   └── engine_provider.dart     # Riverpod state management
├── services/                    # Audio, beat detection, camera rails
├── widgets/
│   ├── bezel/                   # Bottom bezel tab system
│   ├── floating/                # Pullable floating controls
│   ├── canvas/                  # WebGL canvas integration
│   ├── audio/                   # Audio mapping editor
│   └── timeline/                # Keyframe sequencer
└── utils/
    └── vib3_colors.dart         # VIB3 color palette

docs/                            # Complete documentation suite
assets/webgl/                    # vib3-plus-engine assets
```

---

## 🎨 Design Principles

1. **Visualization-First**: 90%+ of screen dedicated to full-screen canvas
2. **Glassmorphic UI**: Translucent overlays (60-85% opacity, 6-12px blur)
3. **Professional Latency**: < 50ms parameter updates
4. **Large Touch Targets**: 60x60+ points for live performance
5. **Adaptive Customization**: Every control can be remapped to any parameter

---

## 🛠️ Development Roadmap

### Phase 1: Core Infrastructure ✅ COMPLETE
- Project structure, state management, core files

### Phase 2: Bezel Tab System (Week 1-2)
- 9 bezel tabs with glassmorphic design
- Parameter controls (XY pads, knobs, faders)

### Phase 3: Floating Control System (Week 3)
- Pullable/collapsible widgets
- Drag-and-drop positioning
- Configuration persistence

### Phase 4: Audio Reactivity (Week 4)
- 7-band FFT analyzer
- Beat/measure detection
- Audio mapping editor

### Phase 5: Choreography Features (Week 5-6)
- Camera rails
- Macro controls
- Palette orbit
- Lighting system

### Phase 6: Multi-Touch Canvas (Week 6)
- 6-degree rotation control
- Multi-finger gesture detection
- Visual feedback system

### Phase 7: Timeline & Sequencing (Week 7)
- Keyframe editor
- Transport controls
- Beat-synced automation

### Phase 8: WebGL Integration (Week 8)
- vib3-plus-engine bundling
- JavaScript bridge
- Parameter synchronization

### Phase 9: Polish & Optimization (Week 9)
- 60fps target
- Adaptive quality
- Haptic feedback
- UX refinement

### Phase 10: Testing & Deployment (Week 10)
- Unit/widget/integration tests
- Android APK build
- Performance profiling

---

## 🌟 A Paul Phillips Manifestation

**Repository**: https://github.com/Domusgpt/projection-vib3

**Contact**: Paul@clearseassolutions.com

**Join The Exoditical Moral Architecture Movement**: [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

---

**© 2025 Paul Phillips - Clear Seas Solutions LLC**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
