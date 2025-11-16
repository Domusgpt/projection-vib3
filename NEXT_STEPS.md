# VIB3 Light Lab - Next Steps

**Current Status**: Phases 1-3 Complete (30%)
**Focus**: Integrate vib3-plus-engine (CONFIRMED best choice)

---

## ✅ **ARCHITECTURE DECISION: vib3-plus-engine**

**Repository**: https://github.com/Domusgpt/vib3-plus-engine/tree/docs-comprehensive-documentation

**Why This Choice**:
- Purpose-built VJ visualization tool with audio reactivity
- 4 rendering systems (Faceted, Quantum, Holographic, Polychora)
- 96 geometries (24 per system)
- State management, presets, gallery system
- Touch-optimized, 60fps desktop / 30-45fps mobile
- Complete web app ready for WebView integration

**WebView + JS Bridge = CORRECT APPROACH**:
- Both vib3-plus-engine and SDK are web-based (no native Dart)
- Current architecture (InAppWebView + JavaScript bridge) is optimal
- Industry standard for VJ/visualization apps
- < 16ms latency achievable (perfect for 60fps)

---

## 🎯 Immediate Priorities (Phase 4)

### 1. Bundle vib3-plus-engine Assets

**Source Repository**: https://github.com/Domusgpt/vib3-plus-engine

**What we need**:
```
assets/webgl/
├── index.html              # Main entry point
├── js/                     # Core engine files
│   ├── core/              # 12 engine files (app.js, state-manager.js, etc.)
│   ├── audio/             # Audio processing
│   ├── controls/          # Input management
│   ├── gallery/           # Gallery system
│   ├── geometry/          # 4D mathematics
│   └── ui/                # UI components
├── src/                   # Additional engine files
│   ├── core/              # 19 engine files (Engine.js, VIB3Engine.js)
│   ├── faceted/           # Faceted rendering system
│   ├── quantum/           # Quantum rendering system
│   ├── holograms/         # Holographic rendering system
│   └── [other systems]
└── styles/                # CSS modules
```

**Steps**:
1. Clone vib3-plus-engine repository:
   ```bash
   cd /tmp
   gh repo clone Domusgpt/vib3-plus-engine
   cd vib3-plus-engine
   gh pr checkout docs-comprehensive-documentation
   ```

2. Copy to Flutter project:
   ```bash
   cp -r * /mnt/c/Users/millz/projection-vib3/assets/webgl/
   ```

3. Update `webgl_canvas.dart` to load from assets
4. Test that engine initializes with all 3 systems

### 2. Configure 3 Core Systems

**Systems to support** (polychora comes later):
- ✅ **Faceted** - Default geometric visualizer
- ✅ **Quantum** - Advanced shader-based
- ✅ **Holographic** - Layered effects

**Implementation**:
- Add system selector buttons to top bar
- Wire up to `setActiveSystem()` in engine provider
- Test switching between all 3 systems

### 3. Add Geometry Selector

**24 Geometries** (from vib3-plus-engine):
- Hypercube (Tesseract)
- 24-Cell
- 120-Cell
- 600-Cell
- 16-Cell
- 5-Cell (Simplex)
- ... (all 24)

**Implementation**:
- Add geometry dropdown/grid in top bar
- Wire up to `setActiveGeometry()`
- Test cycling through geometries

---

## 📋 Detailed Implementation Plan

### Step 1: Get vib3-plus-engine
```bash
# Option A: Clone from GitHub
cd /tmp
gh repo clone Domusgpt/vib3-plus-engine
cp -r vib3-plus-engine/* /mnt/c/Users/millz/projection-vib3/assets/webgl/

# Option B: Download from live site
cd assets/webgl
wget https://domusgpt.github.io/vib3-plus-engine/index.html
wget https://domusgpt.github.io/vib3-plus-engine/vib3-engine.js
# ... (get all necessary files)
```

### Step 2: Update webgl_canvas.dart
```dart
// Replace _getTestHTML() with:
initialFile: 'assets/webgl/index.html',

// Or if using InAppWebViewInitialData:
initialData: InAppWebViewInitialData(
  data: await rootBundle.loadString('assets/webgl/index.html'),
  baseUrl: WebUri('http://localhost/'),
),
```

### Step 3: Add Top Bar UI
Create `lib/widgets/top_bar/control_bar.dart`:
```dart
class ControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          SystemSelector(), // Faceted/Quantum/Holographic
          GeometrySelector(), // 24 geometries
          BPMDisplay(), // Future: audio sync
          PresetButtons(), // Save/Load/Random
        ],
      ),
    );
  }
}
```

### Step 4: Wire Up System Switching
```dart
// In SystemSelector widget:
DropdownButton<String>(
  value: ref.watch(engineProvider).activeSystem,
  items: [
    DropdownMenuItem(value: 'faceted', child: Text('🔷 Faceted')),
    DropdownMenuItem(value: 'quantum', child: Text('⚛️ Quantum')),
    DropdownMenuItem(value: 'holographic', child: Text('🌈 Holographic')),
  ],
  onChanged: (system) {
    ref.read(engineProvider.notifier).setActiveSystem(system!);
  },
)
```

---

## 🔧 Technical Notes

### WebGL Engine API (Expected)
```javascript
// Initialize engine
window.vib3Engine.boot();

// Set active system (faceted/quantum/holographic)
window.vib3Engine.setActiveSystem(systemName);

// Set active geometry (0-23)
window.vib3Engine.setActiveGeometry(geometryIndex);

// Update parameters
window.vib3Engine.setParameter(paramName, value);
window.vib3Engine.applyParameterBatch(paramsObject);

// Get current state
window.vib3Engine.getState();
```

### Flutter → WebGL Parameter Mapping
```dart
// Current Flutter params → WebGL engine params
VIB3Parameters.rotationXY  → 'rotationXY'
VIB3Parameters.rotationXZ  → 'rotationXZ'
VIB3Parameters.rotationYZ  → 'rotationYZ'
VIB3Parameters.rotationXW  → 'rotationXW'
VIB3Parameters.rotationYW  → 'rotationYW'
VIB3Parameters.rotationZW  → 'rotationZW'
// ... (all 44 parameters)
```

---

## 🚀 Quick Start Commands

### Build and Test
```bash
cd /mnt/c/Users/millz/projection-vib3

# Install dependencies (if needed)
flutter pub get

# Run on Chrome for testing
flutter run -d chrome

# Build for web
flutter build web

# Build Android APK
flutter build apk
```

### Deploy to GitHub Pages (Future)
```bash
# Build web version
flutter build web --base-href /projection-vib3/

# Deploy to gh-pages branch
cd build/web
git init
git add -A
git commit -m "Deploy Flutter web app"
git push -f https://github.com/Domusgpt/projection-vib3.git main:gh-pages
```

---

## 📝 Testing Checklist

### Phase 4 Testing
- [ ] vib3-plus-engine assets loaded
- [ ] WebGL canvas renders with actual engine
- [ ] All 3 systems switchable (Faceted/Quantum/Holographic)
- [ ] All 24 geometries selectable
- [ ] Rotation XY pads control visualization
- [ ] Parameters update in real-time (< 16ms latency)
- [ ] No console errors
- [ ] Smooth 60fps rendering

### Integration Testing
- [ ] Bezel tab expand/collapse works
- [ ] XY pads responsive to touch
- [ ] Parameters persist during system/geometry changes
- [ ] WebGL canvas resizes properly
- [ ] Translucent overlay doesn't block interaction

---

## 🎨 UI Enhancements (After Phase 4)

### Top Bar
```
┌─────────────────────────────────────────────────────────────┐
│ [🔷][⚛️][🌈]  Geometry: Tesseract ▼  BPM: -- │ [Save][Load][Random] │
└─────────────────────────────────────────────────────────────┘
```

### Bezel Tabs (Expand to 9)
- [x] 4D Rotate
- [ ] Visual (grid density, morph, chaos, speed)
- [ ] Color (hue, saturation, palette)
- [ ] Audio (7-band analyzer, mappings)
- [ ] Effects (bloom, chromatic aberration, RGB shift)
- [ ] Timeline (keyframe editor)
- [ ] Camera (position, FOV, rails)
- [ ] Lighting (3-point lighting)
- [ ] Macros (multi-parameter controls)

---

## 💡 Pro Tips

### Performance
- Use `applyParameterBatch()` instead of multiple `setParameter()` calls
- Throttle rapid parameter updates (16ms minimum)
- Use `const` constructors where possible
- Lazy-load heavy widgets

### Debugging
```dart
// Enable WebGL console logging
onConsoleMessage: (controller, message) {
  print('WebGL: ${message.message}');
}

// Check parameter updates
void setParameter(VIB3Parameters param, num value) {
  print('📊 ${param.name} = $value');
  // ...
}
```

### Asset Loading Issues
If assets don't load:
1. Check `pubspec.yaml` has `assets/webgl/` listed
2. Run `flutter clean && flutter pub get`
3. Verify files exist in `assets/webgl/`
4. Check InAppWebView permissions (Android manifest)

---

## 🌟 A Paul Phillips Manifestation

**Next Session Goal**: Replace test HTML with vib3-plus-engine and get all 3 systems working!

**Contact**: Paul@clearseassolutions.com
**Repository**: https://github.com/Domusgpt/projection-vib3
