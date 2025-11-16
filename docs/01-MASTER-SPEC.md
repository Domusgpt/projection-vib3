# VIB3 Light Lab - Professional VJ System Architecture

**A Paul Phillips Manifestation**
**Hybrid Bezel + Floating Controls with Advanced Audio Reactivity**

---

## 🎯 Core Architecture: Hybrid Control System

### The Big Idea:
**Every control lives in TWO states and can transition between them:**

1. **Collapsed in Bezel Tab** (default): Translucent, compact, organized by category
2. **Floating Widget** (pulled out): Draggable, resizable, can overlay visualization

Users can **pull controls out** from bezel tabs to work with them, then **push them back** when done.

---

## 📐 Screen Layout: Full Canvas + Hybrid Controls

```
┌─────────────────────────────────────────────────────────────┐
│  [🔷][🌌][✨][🔮]  BPM:128 ♪  [Gallery] [Config]         │ ← Minimal top bar (40px)
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐         FULL WEBGL CANVAS                │
│  │  XY Pad     │         (Multi-touch rotation control)    │ ← Floating controls
│  │  Floating   │                                           │   pulled from bezel
│  │  [Collapse] │              ┌──────────┐                │
│  └─────────────┘              │  Knobs   │                │
│                               │ Floating │                │
│                               └──────────┘                │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ [4D Rotate] [Visual] [Color] [Audio♪] [Effects] [Timeline]│ ← Bezel tabs (50px collapsed)
│  ▌ ▌ ▌ ▌ ▌ ▌  [Expand ↑]                                 │   Tap to expand, shows all controls
└─────────────────────────────────────────────────────────────┘
```

### When a Bezel Tab is Expanded:

```
┌─────────────────────────────────────────────────────────────┐
│  [🔷][🌌][✨][🔮]  BPM:128 ♪  [Gallery] [Config]         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                   WEBGL CANVAS (70% height)                │
│              (translucent controls overlay)                │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ [4D Rotate] [Visual] [Color] [Audio♪] [Effects] [Timeline]│ ← Active tab highlighted
├═════════════════════════════════════════════════════════════┤
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│ │   XY Pad    │  │   XZ Pad    │  │   YZ Pad    │  [Pull]│ ← Expanded section (30% height)
│ │   XW+YW     │  │   Rotation  │  │   Rotation  │  [Out] │   Translucent (70% opacity)
│ │             │  │             │  │             │         │   Each control has [Pull Out] button
│ └─────────────┘  └─────────────┘  └─────────────┘         │
│  XW: 0.0-6.28    XZ: 0.0-6.28    YZ: 0.0-6.28            │
│                                             [Collapse ↓]   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎛️ Bezel Tab Categories

### **Tab 1: 4D ROTATION** (6 rotation planes)
**Collapsed state**: 6 tiny rotation indicators (vertical bars showing current angles)
**Expanded state**:
- 3 large XY pads (XY+ZW, XZ+YZ, XW+YW)
- Each pad has [Pull Out] button → becomes floating draggable widget
- Live rotation values displayed
- Multi-touch canvas control indicator

### **Tab 2: VISUAL** (4 parameters)
**Collapsed state**: 4 mini faders showing current values
**Expanded state**:
- Grid Density: Rotary knob (5-100) + [Pull Out]
- Morph Factor: Fader (0.0-1.0) + [Pull Out]
- Chaos: Rotary knob (0.0-1.0) + [Pull Out]
- Speed: Fader (0.0-5.0) + [Pull Out]
- Each control configurable via dropdown to control ANY parameter

### **Tab 3: COLOR** (3 parameters)
**Collapsed state**: Color preview bar (current HSI)
**Expanded state**:
- Hue: Circular color wheel (0-360°) + [Pull Out]
- Saturation: Fader (0.0-1.0) + [Pull Out]
- Intensity: Fader (0.0-1.0) + [Pull Out]
- Preset color palette (12 colors)

### **Tab 4: AUDIO ♪** (MASSIVE EXPANSION)
**Collapsed state**: Audio waveform visualization + BPM indicator
**Expanded state**:
```
┌─────────────────────────────────────────────────────────────┐
│ AUDIO REACTIVITY CONTROL CENTER                             │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│ │  Low (Bass) │  │  Mid        │  │ High (Treble)│         │
│ │  ▌▌▌▌▌▌▌▌   │  │  ▌▌▌▌▌      │  │  ▌▌▌         │         │ ← FFT visualization
│ └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│ BPM: 128 ♪  Detected   [Manual Override: ___ ]            │
│ Time Signature: [4/4 ▼] (detected or manual)               │
│ Measure: 2/4  Beat: 3/4  ●●●○                             │ ← Beat & measure tracking
├─────────────────────────────────────────────────────────────┤
│ AUDIO → PARAMETER MAPPINGS (User Configurable):            │
│                                                             │
│ ┌─ Mapping 1 ──────────────────────────────────────────┐   │
│ │ Source: [Bass (Low Freq) ▼]  →  Target: [rotationXW]│   │
│ │ Intensity: ▬▬▬▬▬▬●▬▬▬ (0.7)   Range: [0.0 - 6.28]  │   │
│ │ Mode: [Direct ▼] (Direct/Inverted/Smoothed/Triggered)│   │
│ │ Attack: 10ms  Release: 200ms  [✓ Enabled] [Delete]  │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─ Mapping 2 ──────────────────────────────────────────┐   │
│ │ Source: [Beat Trigger ▼]  →  Target: [morphFactor]  │   │
│ │ On Beat: Jump to 1.0, decay to 0.0 over 200ms       │   │
│ │ Trigger on: [Every Beat ▼] (Every/Downbeat/Measures)│   │
│ │ [✓ Enabled] [Delete]                                 │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─ Mapping 3 ──────────────────────────────────────────┐   │
│ │ Source: [Mid Frequency ▼]  →  Target: [cardBend]    │   │
│ │ Intensity: ▬▬▬▬▬●▬▬▬▬ (0.5)   Range: [0.0 - 1.0]   │   │
│ │ Mode: [Smoothed ▼]  Smoothing: 50ms                  │   │
│ │ [✓ Enabled] [Delete]                                 │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                             │
│ [+ Add New Mapping]                                         │
│                                                             │
│ PRESETS: [Kick-Heavy] [Melodic] [Chaotic] [Custom 1]      │
└─────────────────────────────────────────────────────────────┘
```

**Audio Sources Available**:
- Low Frequency (Bass) - 20-250 Hz
- Mid Frequency - 250-2000 Hz
- High Frequency (Treble) - 2000-20000 Hz
- Overall Volume (RMS)
- Beat Trigger (kick detection)
- Downbeat Trigger (measure start)
- Measure Progress (0.0-1.0 through current measure)
- BPM-synced LFO (sine/saw/square waves locked to tempo)

**Target Parameters**:
- All 6 rotation planes
- All 4 visual parameters
- All 3 color parameters
- **Card Bend** (NEW - bends visualization like cards)
- **Perspective Shift** (NEW - changes camera FOV)
- **Layer Opacity** (for multi-canvas systems)

**Mapping Modes**:
- **Direct**: Audio value directly controls parameter
- **Inverted**: 1.0 - audioValue
- **Smoothed**: Exponential moving average with configurable time
- **Triggered**: Jump to value on beat/threshold, decay over time
- **Gated**: Only active when audio exceeds threshold

### **Tab 5: EFFECTS** (NEW)
**Card Bending & Advanced Visual Effects**

```
┌─────────────────────────────────────────────────────────────┐
│ VISUAL EFFECTS                                              │
├─────────────────────────────────────────────────────────────┤
│ ┌─ Card Bend Effect ──────────────────────────────────┐     │
│ │ Bend Amount: ▬▬▬▬▬●▬▬▬▬ (0.5)  [Pull Out]         │     │
│ │ Bend Axis: [X ▼] (X/Y/Z/W/XY/Custom)               │     │
│ │ Audio Reactive: [✓] → [Mid Freq ▼] Intensity: 0.8 │     │
│ │ XY Pad Control: [✓] → X=BendAmount, Y=BendSpeed   │     │
│ └────────────────────────────────────────────────────┘     │
│                                                             │
│ ┌─ Perspective Shift ──────────────────────────────────┐    │
│ │ FOV: ▬▬▬▬▬▬●▬▬▬ (60°)  [Pull Out]                  │    │
│ │ Audio Reactive: [✓] → [Bass ▼] Intensity: 0.6      │    │
│ └────────────────────────────────────────────────────┘    │
│                                                             │
│ ┌─ Multi-Layer Compositing ────────────────────────────┐   │
│ │ Layer 1: [Faceted ▼]   Opacity: ▬▬▬▬▬▬▬▬●▬ (0.9)  │   │
│ │ Layer 2: [Quantum ▼]   Opacity: ▬▬▬▬●▬▬▬▬▬ (0.5)  │   │
│ │ Layer 3: [Off ▼]       Opacity: ▬●▬▬▬▬▬▬▬▬ (0.1)  │   │
│ │ Blend Mode: [Additive ▼] (Add/Multiply/Screen/Overlay)│  │
│ └────────────────────────────────────────────────────┘    │
│                                                             │
│ ┌─ Post-Processing ────────────────────────────────────┐   │
│ │ Bloom: ▬▬▬●▬▬▬▬▬▬ (0.3)  [Pull Out]                │   │
│ │ Chromatic Aberration: ▬▬●▬▬▬▬▬▬▬ (0.2)             │   │
│ │ RGB Shift: ▬●▬▬▬▬▬▬▬▬ (0.1)                        │   │
│ └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### **Tab 6: TIMELINE** (NEW - Sequencing System)
**For programming changes over time**

```
┌─────────────────────────────────────────────────────────────┐
│ TIMELINE SEQUENCER                                          │
├─────────────────────────────────────────────────────────────┤
│ Transport: [▶ Play] [⏸ Pause] [⏹ Stop] [⏺ Record]        │
│ Playhead: ──────●──────────────── (8.5s / 32s)             │
│ BPM: 128 ♪  Time Sig: 4/4  Loop: [✓] (4 measures)        │
├─────────────────────────────────────────────────────────────┤
│ Track 1: Rotation XW                                        │
│ │─────────────────────────────────────────────────────────│ │
│ │ ╔══╗         ╔══╗         ╔══╗         ╔══╗            │ │ ← Keyframes
│ │ 0.0   →   3.14   →   6.28   →   0.0                    │ │
│ │ (Bar 1)   (Bar 2)   (Bar 3)   (Bar 4)                  │ │
│ │─────────────────────────────────────────────────────────│ │
│                                                             │
│ Track 2: Hue (Color Cycling)                               │
│ │─────────────────────────────────────────────────────────│ │
│ │ ╔══════════════════════════════════════════════════════│ │ ← Automation curve
│ │ 0° ────────────────────────→ 360°                      │ │
│ │─────────────────────────────────────────────────────────│ │
│                                                             │
│ Track 3: Beat-Triggered Morph                              │
│ │─────────────────────────────────────────────────────────│ │
│ │ ▮   ▮   ▮   ▮   ▮   ▮   ▮   ▮                         │ │ ← Trigger events
│ │ (every beat: morphFactor → 1.0, decay to 0.0)          │ │
│ │─────────────────────────────────────────────────────────│ │
│                                                             │
│ [+ Add Track]                                               │
│                                                             │
│ Preset Sequences: [Intro] [Build] [Drop] [Breakdown]      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Translucency & Visibility Design Language

### State-Based Opacity:

| State | Opacity | Blur | Visual Cue |
|-------|---------|------|------------|
| **Bezel Tab (Collapsed)** | 70% | 6px | Thin line with icon + value preview |
| **Bezel Tab (Expanded)** | 75% | 8px | Full controls visible, 30% screen height |
| **Floating Widget (Inactive)** | 65% | 10px | Dim border (white 30%) |
| **Floating Widget (Active)** | 80% | 12px | Bright border (accent color 80%) |
| **Floating Widget (Dragging)** | 85% | 4px | Glowing border + shadow |
| **Multi-Touch Canvas (Active)** | 0% | 0px | **Border glow only** (changes color by finger count) |

### Visual Grouping & State Indicators:

**Color Coding**:
- **Cyan**: Rotation parameters (4D planes)
- **Magenta**: Visual parameters (grid, morph, chaos, speed)
- **Purple**: Color parameters (HSI)
- **Green**: Audio reactivity (active mapping indicator)
- **Orange**: Effects (card bend, bloom, etc.)
- **Blue**: Timeline/sequencing

**Active State Indicators**:
- **Pulsing glow**: Parameter is audio-reactive
- **Animated border**: Parameter is being controlled by XY pad
- **Beat flash**: Parameter responds to beat triggers
- **Moving gradient**: Parameter has timeline automation active

---

## 👆 Multi-Touch Canvas Rotation Control (SIMPLIFIED & ELEGANT)

### Visual Feedback: **Border Glow Color Only**

No overlays, no crosshairs, no triangles - just the **screen border changes color** based on finger count:

| Fingers | Rotation Planes | Border Color |
|---------|----------------|--------------|
| **1** | XW + YW | **Purple** solid glow |
| **2** | XY + ZW | **Cyan** solid glow |
| **3** | XZ + YZ | **Magenta** solid glow |
| **4+** | All 6 planes | **Rainbow gradient** glow |

```dart
class MultiTouchCanvasFeedback extends StatelessWidget {
  final int fingerCount;

  @override
  Widget build(BuildContext context) {
    if (fingerCount == 0) return SizedBox.shrink();

    Color borderColor;
    switch (fingerCount) {
      case 1: borderColor = VIB3Colors.purple; break;
      case 2: borderColor = VIB3Colors.cyan; break;
      case 3: borderColor = VIB3Colors.magenta; break;
      default: borderColor = VIB3Colors.rainbow; break;
    }

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Small indicator badge** (top-right, 40x40px):
```
┌──────┐
│ 👆👆  │  ← Finger count + color-coded
│ XY+ZW│  ← Active planes label
└──────┘
```

---

## 🎚️ Floating Widget System

### Pull Out / Collapse Mechanism:

**In Bezel Tab**:
```
┌─────────────────────┐
│  XY Pad - XW+YW     │
│  ┌───────────┐      │
│  │  Current  │ [📌] │ ← Pull Out button (pin icon)
│  │  Position │      │
│  └───────────┘      │
│  XW: 2.14  YW: 4.56 │
└─────────────────────┘
```

**After Pulling Out**:
```
Floating widget appears on canvas with:
┌─────────────────────┐
│ XY Pad - XW+YW   [▼]│ ← Collapse button (back to bezel)
│ ┌─────────────────┐ │
│ │                 │ │
│ │   Touch Area    │ │
│ │                 │ │
│ └─────────────────┘ │
│ XW: 2.14  YW: 4.56  │
│ [⚙️] [🔗]           │ ← Config & Audio Link buttons
└─────────────────────┘
```

**Dragging**:
- Long press → drag handle appears
- Can resize by dragging corners
- Snap to edges/other widgets (magnetic snapping)
- Can minimize to icon (stays on canvas, smaller)

### Flutter Implementation:

```dart
class PullableControl extends StatefulWidget {
  final Widget controlWidget;
  final String controlId;
  final VIB3ControlCategory category;

  @override
  State<PullableControl> createState() => _PullableControlState();
}

class _PullableControlState extends State<PullableControl> {
  bool isPulledOut = false;
  Offset position = Offset(100, 100);
  Size size = Size(200, 200);

  @override
  Widget build(BuildContext context) {
    if (!isPulledOut) {
      // COLLAPSED STATE (in bezel)
      return _buildBezelVersion();
    } else {
      // FLOATING STATE (on canvas)
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: GestureDetector(
          onPanUpdate: _handleDrag,
          child: GlassmorphicContainer(
            opacity: 0.65,
            blur: 10,
            borderColor: widget.category.color,
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                // Header with collapse button
                _buildFloatingHeader(),

                // The actual control
                Expanded(child: widget.controlWidget),

                // Footer with config buttons
                _buildFloatingFooter(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildBezelVersion() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.category.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.category.color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Compact version of control
          Expanded(child: widget.controlWidget),

          // Pull Out button
          IconButton(
            icon: Icon(Icons.push_pin, color: widget.category.color, size: 18),
            onPressed: () => setState(() => isPulledOut = true),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.category.color.withOpacity(0.3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.controlId,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
            onPressed: () => setState(() => isPulledOut = false),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingFooter() {
    return Container(
      padding: EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Config button
          IconButton(
            icon: Icon(Icons.settings, color: widget.category.color, size: 16),
            onPressed: _showConfigDialog,
          ),

          // Audio link button
          IconButton(
            icon: Icon(Icons.graphic_eq, color: Colors.green, size: 16),
            onPressed: _showAudioMappingDialog,
          ),
        ],
      ),
    );
  }

  void _handleDrag(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });
  }

  void _showConfigDialog() {
    // Show dropdown to change which parameters this control affects
  }

  void _showAudioMappingDialog() {
    // Show audio reactivity configuration
  }
}
```

---

## 🎵 Audio Reactivity Engine

### Beat Detection System:

```dart
class AudioBeatEngine {
  double bpm = 128.0;
  bool autoDetect = true;
  TimeSignature timeSignature = TimeSignature.fourFour;

  int currentMeasure = 1;
  int currentBeat = 1;
  double beatProgress = 0.0; // 0.0 - 1.0 within current beat
  double measureProgress = 0.0; // 0.0 - 1.0 within current measure

  // FFT analysis
  List<double> frequencyBands = List.filled(512, 0.0);
  double bassLevel = 0.0;    // 20-250 Hz
  double midLevel = 0.0;     // 250-2000 Hz
  double trebleLevel = 0.0;  // 2000-20000 Hz

  // Beat detection
  bool kickDetected = false;
  double kickThreshold = 0.6;
  int beatsSinceDownbeat = 0;

  void update(AudioBuffer buffer) {
    // Perform FFT analysis
    _analyzeFrequencies(buffer);

    // Detect beats (kick drum)
    kickDetected = _detectKick();

    // Update beat/measure counters
    if (kickDetected) {
      currentBeat++;
      beatsSinceDownbeat++;

      if (beatsSinceDownbeat >= timeSignature.beatsPerMeasure) {
        currentMeasure++;
        beatsSinceDownbeat = 0;
      }
    }

    // Update progress values
    beatProgress = _calculateBeatProgress();
    measureProgress = beatsSinceDownbeat / timeSignature.beatsPerMeasure;
  }

  bool _detectKick() {
    // Simple energy-based kick detection
    // Check if bass level exceeds threshold and is peak in recent window
    return bassLevel > kickThreshold && _isLocalMaximum(bassLevel);
  }

  void _analyzeFrequencies(AudioBuffer buffer) {
    // FFT analysis → populate frequencyBands
    // Bin bands into bass/mid/treble
    bassLevel = _averageBands(0, 40);
    midLevel = _averageBands(40, 200);
    trebleLevel = _averageBands(200, 512);
  }
}

class AudioParameterMapping {
  final AudioSource source;
  final String targetParameter;
  final double intensity;
  final AudioMappingMode mode;
  final double attackMs;
  final double releaseMs;
  final bool enabled;

  AudioParameterMapping({
    required this.source,
    required this.targetParameter,
    this.intensity = 1.0,
    this.mode = AudioMappingMode.direct,
    this.attackMs = 10,
    this.releaseMs = 200,
    this.enabled = true,
  });

  double apply(double audioValue, double previousValue) {
    if (!enabled) return previousValue;

    double mappedValue;

    switch (mode) {
      case AudioMappingMode.direct:
        mappedValue = audioValue * intensity;
        break;

      case AudioMappingMode.inverted:
        mappedValue = (1.0 - audioValue) * intensity;
        break;

      case AudioMappingMode.smoothed:
        // Exponential moving average
        final alpha = 1.0 - exp(-16.67 / releaseMs); // 60fps
        mappedValue = previousValue + alpha * (audioValue - previousValue);
        break;

      case AudioMappingMode.triggered:
        // Jump to value on trigger, decay back
        if (audioValue > 0.8) {
          mappedValue = intensity;
        } else {
          mappedValue = previousValue * exp(-16.67 / releaseMs);
        }
        break;
    }

    return mappedValue;
  }
}

enum AudioSource {
  bassLevel,
  midLevel,
  trebleLevel,
  overallVolume,
  beatTrigger,
  downbeatTrigger,
  measureProgress,
  bpmLFO,
}

enum AudioMappingMode {
  direct,
  inverted,
  smoothed,
  triggered,
  gated,
}
```

---

## 📊 Complete Parameter List (ALL Controls)

### 6 Rotation Planes:
1. **XY Rotation** (standard horizontal spin)
2. **XZ Rotation** (vertical tilt)
3. **YZ Rotation** (depth rotation)
4. **XW Rotation** (hyperspace tilt 1)
5. **YW Rotation** (hyperspace tilt 2)
6. **ZW Rotation** (hyperspace depth)

### 4 Visual Parameters:
7. **Grid Density** (5-100)
8. **Morph Factor** (0.0-1.0)
9. **Chaos** (0.0-1.0)
10. **Speed** (0.0-5.0)

### 3 Color Parameters:
11. **Hue** (0-360°)
12. **Saturation** (0.0-1.0)
13. **Intensity** (0.0-1.0)

### NEW Effect Parameters:
14. **Card Bend** (0.0-1.0) - Bends visualization like playing cards
15. **Card Bend Axis** (X/Y/Z/W/XY/Custom)
16. **Perspective FOV** (30°-120°)
17. **Layer 1 Opacity** (0.0-1.0)
18. **Layer 2 Opacity** (0.0-1.0)
19. **Layer 3 Opacity** (0.0-1.0)
20. **Blend Mode** (Add/Multiply/Screen/Overlay)
21. **Bloom** (0.0-1.0)
22. **Chromatic Aberration** (0.0-1.0)
23. **RGB Shift** (0.0-1.0)

### Geometry Selection:
24. **Geometry Type** (24 options across 4 systems)
25. **System Type** (Faceted/Quantum/Holographic/Polychora)

**Total: 25+ configurable parameters**

---

## 🎭 Elegant Design Patterns

### Minimalist Visual Language:
- **No unnecessary chrome** - Controls are functional, not decorative
- **Consistent color coding** - Same colors always mean same categories
- **State transitions are smooth** - 200ms animations for pull-out/collapse
- **Haptic feedback** - Vibration on control interactions (mobile)
- **Gesture-first** - Touch is primary, mouse is secondary

### Scalability:
- **New parameters easy to add** - Just extend VIB3Parameters enum
- **New audio sources pluggable** - AudioSource enum + FFT analyzer
- **Timeline tracks expandable** - Add tracks dynamically
- **Effect presets shareable** - Export/import JSON

---

## 🚀 Implementation Priority

### Phase 1: Core Hybrid System
1. ✅ Bezel tab system with 6 categories
2. ✅ Pull-out/collapse mechanism for controls
3. ✅ Floating widget dragging & resizing
4. ✅ Translucent overlay system
5. ✅ Multi-touch border feedback (simple color glow)

### Phase 2: Audio Reactivity
1. ✅ FFT audio analysis (bass/mid/treble)
2. ✅ BPM detection & beat tracking
3. ✅ Measure awareness (time signatures)
4. ✅ User-configurable audio→parameter mappings
5. ✅ Audio mapping presets (Kick-Heavy, Melodic, etc.)

### Phase 3: Advanced Effects
1. ✅ Card bend effect with axis control
2. ✅ Multi-layer compositing (3 layers)
3. ✅ Post-processing effects (bloom, chromatic aberration, RGB shift)
4. ✅ Effect audio-reactivity integration

### Phase 4: Timeline Sequencer
1. ✅ Timeline UI with playhead
2. ✅ Keyframe animation system
3. ✅ Beat-synced trigger events
4. ✅ Timeline presets (Intro/Build/Drop/Breakdown)
5. ✅ Loop/transport controls

---

## 🎬 CHOREOGRAPHY ENGINE INTEGRATION

### From vib34d-choreography-engine - The Best Features

The VIB34D Choreography Engine provides cinematic automation, advanced audio analysis, and intelligent visual sequencing. We're integrating ALL of these capabilities:

---

### 📹 Camera Rails & Preset System

**Cinematic Camera Movement Along Predefined Paths**

```
┌─────────────────────────────────────────────────────────────┐
│ CAMERA CONTROL CENTER                                       │
├─────────────────────────────────────────────────────────────┤
│ Active Camera: [Free Orbit ▼]                               │
│   • Free Orbit (user controlled)                            │
│   • Cinematic Rail 1 (circular orbit, 30s loop)            │
│   • Cinematic Rail 2 (zoom in/out, beat-synced)            │
│   • Cinematic Rail 3 (figure-8 path, measure-locked)       │
│   • Camera Preset 1-8 (saved positions)                     │
├─────────────────────────────────────────────────────────────┤
│ ┌─ Camera Position ──────────────────────────────────┐      │
│ │ X: ▬▬▬▬▬●▬▬▬▬ (0.0)    Y: ▬▬▬▬●▬▬▬▬▬ (0.0)     │      │
│ │ Z: ▬▬▬▬▬▬●▬▬▬ (5.0)    FOV: ▬▬▬▬▬▬●▬▬▬ (60°)  │      │
│ │ [Save as Preset ▼]  [Add to Rail ▼]              │      │
│ └───────────────────────────────────────────────────┘      │
│                                                             │
│ ┌─ Rail Editor ──────────────────────────────────────┐      │
│ │ Rail: [Cinematic Rail 1 ▼]  Duration: 30s         │      │
│ │                                                     │      │
│ │ Keyframe Timeline:                                 │      │
│ │ │───●─────────●─────────●─────────●───────│       │      │
│ │ 0s   7.5s    15s      22.5s     30s               │      │
│ │                                                     │      │
│ │ Path Type: [Circular ▼] (Linear/Circular/Bezier)  │      │
│ │ Easing: [Smooth ▼] (Linear/EaseIn/EaseOut/Bounce) │      │
│ │ Loop Mode: [Continuous ▼] (Once/Loop/PingPong)    │      │
│ │                                                     │      │
│ │ Beat Sync: [✓] Lock to: [4 Measures ▼]           │      │
│ │ Audio Reactive: [ ] Zoom on bass hits              │      │
│ └───────────────────────────────────────────────────┘      │
│                                                             │
│ Presets: [Dolly Zoom] [Orbital] [Flyby] [Spiral]          │
└─────────────────────────────────────────────────────────────┘
```

**Camera System Code**:

```dart
class CameraRailSystem {
  List<CameraRail> rails = [];
  CameraPreset currentMode = CameraPreset.freeOrbit;

  void update(double deltaTime, AudioBeatEngine audio) {
    if (currentMode.isRail()) {
      final rail = rails[currentMode.railIndex];

      // Update position along rail
      rail.progress += deltaTime / rail.duration;

      // Beat sync if enabled
      if (rail.beatSynced) {
        rail.progress = audio.measureProgress;
      }

      // Loop handling
      if (rail.progress >= 1.0) {
        switch (rail.loopMode) {
          case LoopMode.once:
            rail.progress = 1.0;
            break;
          case LoopMode.loop:
            rail.progress = rail.progress % 1.0;
            break;
          case LoopMode.pingPong:
            rail.direction *= -1;
            rail.progress = 0.0;
            break;
        }
      }

      // Calculate camera position
      final position = rail.getPositionAt(rail.progress);
      final target = rail.getTargetAt(rail.progress);

      // Audio reactivity
      if (rail.audioReactive) {
        position.z += audio.bassLevel * rail.audioIntensity;
      }

      // Apply to camera
      setCameraPosition(position, target);
    }
  }
}

class CameraRail {
  final String name;
  final List<CameraKeyframe> keyframes;
  final PathType pathType;
  final EasingFunction easing;
  final LoopMode loopMode;
  final double duration;
  final bool beatSynced;
  final bool audioReactive;
  final double audioIntensity;

  double progress = 0.0;
  int direction = 1;

  Vector3 getPositionAt(double t) {
    t = easing.apply(t);

    switch (pathType) {
      case PathType.linear:
        return _interpolateLinear(t);
      case PathType.circular:
        return _interpolateCircular(t);
      case PathType.bezier:
        return _interpolateBezier(t);
    }
  }

  Vector3 _interpolateCircular(double t) {
    final angle = t * 2 * pi;
    final radius = keyframes[0].position.length();
    return Vector3(
      cos(angle) * radius,
      sin(angle) * radius,
      keyframes[0].position.z,
    );
  }
}

enum CameraPreset {
  freeOrbit,
  cinematicRail1,
  cinematicRail2,
  cinematicRail3,
  preset1,
  preset2,
  // ... up to preset8
}
```

---

### 🎛️ Macro Control System

**High-Level Control Abstractions** that map to multiple parameters simultaneously:

```
┌─────────────────────────────────────────────────────────────┐
│ MACRO CONTROLS                                              │
├─────────────────────────────────────────────────────────────┤
│ ┌─ Macro 1: "Intensity Sweep" ────────────────────────┐     │
│ │ Master: ▬▬▬▬▬▬●▬▬▬ (0.6)  [Pull Out]              │     │
│ │                                                      │     │
│ │ Affects:                                            │     │
│ │   • Brightness: 0.6 × 1.0 = 0.6                    │     │
│ │   • Saturation: 0.6 × 0.8 = 0.48                   │     │
│ │   • Speed: 0.6 × 2.0 = 1.2                         │     │
│ │   • Grid Density: 0.6 × 100 = 60                   │     │
│ │                                                      │     │
│ │ Audio Reactive: [✓] → [Overall Volume ▼]          │     │
│ │ [Edit Mappings]                                     │     │
│ └────────────────────────────────────────────────────┘     │
│                                                             │
│ ┌─ Macro 2: "Rotation Complexity" ──────────────────┐      │
│ │ Master: ▬▬▬●▬▬▬▬▬▬ (0.3)  [Pull Out]              │      │
│ │                                                      │      │
│ │ Affects:                                            │      │
│ │   • XW Rotation: 0.3 × 6.28 = 1.88                │      │
│ │   • YW Rotation: 0.3 × 6.28 = 1.88                │      │
│ │   • ZW Rotation: 0.3 × 3.14 = 0.94                │      │
│ │   • Morph Factor: 0.3                              │      │
│ │                                                      │      │
│ │ Audio Reactive: [✓] → [Mid Frequency ▼]           │      │
│ │ [Edit Mappings]                                     │      │
│ └────────────────────────────────────────────────────┘      │
│                                                             │
│ ┌─ Macro 3: "Color Chaos" ───────────────────────────┐     │
│ │ Master: ▬▬▬▬▬▬▬▬●▬ (0.8)  [Pull Out]              │     │
│ │                                                      │     │
│ │ Affects:                                            │     │
│ │   • Hue: Orbiting palette (beat-synced)           │     │
│ │   • Saturation: 0.8                                │     │
│ │   • Chaos Parameter: 0.8                           │     │
│ │   • RGB Shift: 0.8 × 0.5 = 0.4                    │     │
│ │                                                      │     │
│ │ Audio Reactive: [✓] → [Beat Trigger ▼]            │     │
│ │ Palette: [Rainbow ▼] [Edit Orbit]                  │     │
│ └────────────────────────────────────────────────────┘     │
│                                                             │
│ [+ Create New Macro]                                        │
│                                                             │
│ Preset Macros: [Buildup] [Drop] [Chill] [Chaos]           │
└─────────────────────────────────────────────────────────────┘
```

**Macro Implementation**:

```dart
class MacroControl {
  final String name;
  final Map<String, MacroMapping> parameterMappings;
  double masterValue = 0.0;

  AudioReactivityConfig? audioReactive;

  void updateMaster(double newValue) {
    masterValue = newValue;

    // Apply to all mapped parameters
    parameterMappings.forEach((param, mapping) {
      final finalValue = mapping.calculateValue(masterValue);
      engineProvider.setParameter(param, finalValue);
    });
  }

  void applyAudioReactivity(double audioValue) {
    if (audioReactive != null && audioReactive.enabled) {
      final reactiveValue = audioValue * audioReactive.intensity;
      updateMaster(masterValue + reactiveValue);
    }
  }
}

class MacroMapping {
  final double scale;      // Multiplier
  final double offset;     // Base value
  final double power;      // Curve (1.0 = linear, 2.0 = quadratic, etc.)

  double calculateValue(double master) {
    return offset + (pow(master, power) * scale);
  }
}

// Example: "Intensity Sweep" macro
final intensitySweep = MacroControl(
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
    enabled: true,
  ),
);
```

---

### 🎵 7-Band Audio Analyzer (Enhanced Granularity)

**Beyond Bass/Mid/Treble** - Professional 7-band frequency analysis:

```
┌─────────────────────────────────────────────────────────────┐
│ ADVANCED AUDIO ANALYZER (7-BAND)                            │
├─────────────────────────────────────────────────────────────┤
│ ┌────┬────┬────┬────┬────┬────┬────┐                       │
│ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌  │ ▌  │  ← Live FFT bars     │
│ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌  │ ▌  │                       │
│ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌  │ ▌  │    │                       │
│ │ ▌▌ │ ▌▌ │ ▌▌ │ ▌  │ ▌  │    │    │                       │
│ └────┴────┴────┴────┴────┴────┴────┘                       │
│  Sub  Bas Low Mid Hi  Pres Air                             │
│  20-  60- 250 1k- 4k- 8k- 16k+                             │
│  60Hz 250 1kHz 4kHz 8kHz 16k  20k                          │
├─────────────────────────────────────────────────────────────┤
│ ONSET DETECTION & BPM ANALYSIS                              │
│                                                             │
│ BPM: 128.4 ♪ (Auto-detected)  Confidence: ████████ 87%    │
│ Last Onset: 145ms ago  ●  Threshold: ▬▬▬▬●▬▬▬▬▬ (0.4)     │
│                                                             │
│ Beat Visualization: ●●●○ (3/4 through current beat)        │
│ Measure: 2/4  ║▌▌▌▌│▌▌▌▌│▌▌▌░│░░░░║                      │
│                                                             │
│ Onset Sensitivity: ▬▬▬▬▬●▬▬▬▬ (0.5)                       │
│ Attack Speed: Fast ▬●▬▬▬ Slow                              │
│ Release Speed: Fast ▬▬▬●▬ Slow                             │
├─────────────────────────────────────────────────────────────┤
│ BAND-SPECIFIC AUDIO MAPPINGS                                │
│                                                             │
│ ┌─ Sub (20-60 Hz) ─────────────────────────────────┐       │
│ │ Level: ▌▌▌▌▌▌▌░ (0.87)                          │       │
│ │ → rotationXW  Intensity: 0.9  [Smoothed 50ms]    │       │
│ │ → cardBend    Intensity: 0.6  [Direct]           │       │
│ └──────────────────────────────────────────────────┘       │
│                                                             │
│ ┌─ Bass (60-250 Hz) ───────────────────────────────┐       │
│ │ Level: ▌▌▌▌▌▌░░ (0.75)                          │       │
│ │ → morphFactor  Intensity: 0.8  [Triggered]       │       │
│ │ → intensity    Intensity: 0.5  [Smoothed 100ms]  │       │
│ └──────────────────────────────────────────────────┘       │
│                                                             │
│ ┌─ Presence (8-16 kHz) ─────────────────────────────┐      │
│ │ Level: ▌▌░░░░░░ (0.25)                            │      │
│ │ → hue          Intensity: 1.0  [Palette Orbit]    │      │
│ │ → bloom        Intensity: 0.7  [Direct]           │      │
│ └────────────────────────────────────────────────────┘      │
│                                                             │
│ [Configure All 7 Bands →]                                  │
└─────────────────────────────────────────────────────────────┘
```

**7-Band Analyzer Implementation**:

```dart
class SevenBandAudioAnalyzer {
  // Frequency bands (Hz ranges)
  static const bands = [
    FrequencyBand('Sub',      20,   60),   // Sub-bass
    FrequencyBand('Bass',     60,   250),  // Bass
    FrequencyBand('Low Mid',  250,  1000), // Low midrange
    FrequencyBand('Mid',      1000, 4000), // Midrange
    FrequencyBand('High Mid', 4000, 8000), // High midrange
    FrequencyBand('Presence', 8000, 16000), // Presence
    FrequencyBand('Air',      16000, 20000), // Air/brilliance
  ];

  List<double> bandLevels = List.filled(7, 0.0);
  List<double> bandPeaks = List.filled(7, 0.0);
  List<double> onsetHistory = List.filled(10, 0.0);

  double onsetThreshold = 0.4;
  double onsetSensitivity = 0.5;
  bool onsetDetected = false;

  void analyze(Float32List fftData, int sampleRate) {
    final binSize = sampleRate / fftData.length;

    // Analyze each band
    for (var i = 0; i < bands.length; i++) {
      final band = bands[i];
      final startBin = (band.minFreq / binSize).floor();
      final endBin = (band.maxFreq / binSize).ceil();

      // Calculate RMS energy in this band
      double energy = 0.0;
      for (var bin = startBin; bin < endBin && bin < fftData.length; bin++) {
        energy += fftData[bin] * fftData[bin];
      }
      energy = sqrt(energy / (endBin - startBin));

      // Smooth with previous value
      bandLevels[i] = bandLevels[i] * 0.7 + energy * 0.3;

      // Track peaks with decay
      bandPeaks[i] = max(bandPeaks[i] * 0.95, bandLevels[i]);
    }

    // Onset detection (transient analysis)
    _detectOnsets();
  }

  void _detectOnsets() {
    // Calculate spectral flux (change in spectrum)
    double flux = 0.0;
    for (var i = 0; i < bandLevels.length; i++) {
      final diff = max(0, bandLevels[i] - onsetHistory.first);
      flux += diff * diff;
    }
    flux = sqrt(flux);

    // Update onset history
    onsetHistory.insert(0, flux);
    if (onsetHistory.length > 10) onsetHistory.removeLast();

    // Calculate adaptive threshold
    final meanFlux = onsetHistory.reduce((a, b) => a + b) / onsetHistory.length;
    final threshold = meanFlux * (1.0 + onsetSensitivity);

    // Detect onset
    onsetDetected = flux > threshold && flux > onsetThreshold;
  }
}

class FrequencyBand {
  final String name;
  final double minFreq;
  final double maxFreq;

  const FrequencyBand(this.name, this.minFreq, this.maxFreq);
}
```

---

### 🎨 Audio-Triggered Palette Swaps with Lab Blending

**Intelligent Color Palette System** with perceptually-uniform Lab color space blending:

```
┌─────────────────────────────────────────────────────────────┐
│ COLOR PALETTE SYSTEM                                        │
├─────────────────────────────────────────────────────────────┤
│ Active Palette: [Sunset Vibes ▼]                            │
│                                                             │
│ ┌─ Current Palette ──────────────────────────────────┐      │
│ │ ████ ████ ████ ████ ████ ████ ████ ████           │      │
│ │  1    2    3    4    5    6    7    8             │      │
│ │ #FF5733 #FFC300 #DAF7A6 #33FF57 #33C4FF ...       │      │
│ └────────────────────────────────────────────────────┘      │
│                                                             │
│ ┌─ Palette Orbit (Auto Color Cycling) ──────────────┐      │
│ │ Mode: [Circular Orbit ▼]                           │      │
│ │   • Circular Orbit (rotate through palette)       │      │
│ │   • Ping-Pong (back and forth)                    │      │
│ │   • Random Walk (perlin noise path)               │      │
│ │   • Beat-Triggered Swap (jump on beat)            │      │
│ │                                                     │      │
│ │ Orbit Speed: ▬▬▬●▬▬▬▬▬▬ (0.3)  BPM Sync: [✓]     │      │
│ │ Blend Mode: [Lab Interpolation ▼]                  │      │
│ │   • Lab (perceptually uniform) ✓                  │      │
│ │   • RGB (direct mix)                               │      │
│ │   • HSV (hue rotation)                             │      │
│ │                                                     │      │
│ │ Current Position: ●──────── (12% through cycle)    │      │
│ └────────────────────────────────────────────────────┘      │
│                                                             │
│ ┌─ Audio-Triggered Palette Swap ──────────────────────┐    │
│ │ Trigger: [Beat (Kick) ▼]                            │    │
│ │   • Every Beat                                      │    │
│ │   • Downbeat (measure start)                       │    │
│ │   • Bass Threshold (manual)                        │    │
│ │   • Onset Detection                                │    │
│ │                                                     │    │
│ │ Swap Type: [Next in Sequence ▼]                    │    │
│ │   • Next palette in library                        │    │
│ │   • Random palette                                 │    │
│ │   • Complementary shift                            │    │
│ │   • Analogous shift                                │    │
│ │                                                     │    │
│ │ Transition: 200ms [Crossfade with Lab blending]    │    │
│ │ [✓] Enabled                                        │    │
│ └────────────────────────────────────────────────────┘    │
│                                                             │
│ Preset Palettes:                                            │
│ [Sunset Vibes] [Ocean Depths] [Neon Nights] [Forest]      │
│ [Cyberpunk] [Pastel Dreams] [Fire & Ice] [Monochrome]     │
│                                                             │
│ [Create Custom Palette]  [Import from Image]               │
└─────────────────────────────────────────────────────────────┘
```

**Lab Color Blending Code**:

```dart
class PaletteOrbitSystem {
  List<Color> currentPalette = [];
  PaletteOrbitMode orbitMode = PaletteOrbitMode.circular;
  double orbitSpeed = 0.3;
  double orbitPosition = 0.0;
  bool bpmSynced = true;

  PaletteSwapConfig? audioSwap;

  Color getCurrentColor(AudioBeatEngine audio) {
    // Update orbit position
    if (bpmSynced) {
      orbitPosition = audio.measureProgress;
    } else {
      orbitPosition += orbitSpeed * 0.016; // 60fps
      orbitPosition %= 1.0;
    }

    // Get color based on orbit mode
    switch (orbitMode) {
      case PaletteOrbitMode.circular:
        return _circularOrbit();
      case PaletteOrbitMode.pingPong:
        return _pingPongOrbit();
      case PaletteOrbitMode.randomWalk:
        return _randomWalkOrbit();
      case PaletteOrbitMode.beatTriggered:
        return _beatTriggeredOrbit(audio);
    }
  }

  Color _circularOrbit() {
    // Interpolate between palette colors using Lab color space
    final scaledPos = orbitPosition * currentPalette.length;
    final index1 = scaledPos.floor() % currentPalette.length;
    final index2 = (index1 + 1) % currentPalette.length;
    final t = scaledPos - scaledPos.floor();

    return labInterpolate(currentPalette[index1], currentPalette[index2], t);
  }

  Color labInterpolate(Color c1, Color c2, double t) {
    // Convert RGB to Lab color space
    final lab1 = rgbToLab(c1);
    final lab2 = rgbToLab(c2);

    // Interpolate in Lab space (perceptually uniform)
    final labMix = LabColor(
      lab1.l + (lab2.l - lab1.l) * t,
      lab1.a + (lab2.a - lab1.a) * t,
      lab1.b + (lab2.b - lab1.b) * t,
    );

    // Convert back to RGB
    return labToRgb(labMix);
  }

  LabColor rgbToLab(Color rgb) {
    // RGB → XYZ → Lab conversion
    // (Perceptually uniform color space)
    final r = _gammaCorrect(rgb.red / 255.0);
    final g = _gammaCorrect(rgb.green / 255.0);
    final b = _gammaCorrect(rgb.blue / 255.0);

    final x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    final y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    final z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    final l = 116 * _labF(y / 1.0) - 16;
    final a = 500 * (_labF(x / 0.95047) - _labF(y / 1.0));
    final bValue = 200 * (_labF(y / 1.0) - _labF(z / 1.08883));

    return LabColor(l, a, bValue);
  }

  double _gammaCorrect(double c) {
    return c > 0.04045 ? pow((c + 0.055) / 1.055, 2.4) : c / 12.92;
  }

  double _labF(double t) {
    return t > 0.008856 ? pow(t, 1.0 / 3.0) : 7.787 * t + 16.0 / 116.0;
  }
}

class PaletteSwapConfig {
  final AudioTrigger trigger;
  final SwapType swapType;
  final int transitionMs;
  bool enabled;

  PaletteSwapConfig({
    required this.trigger,
    required this.swapType,
    this.transitionMs = 200,
    this.enabled = true,
  });
}

enum PaletteOrbitMode {
  circular,
  pingPong,
  randomWalk,
  beatTriggered,
}

enum AudioTrigger {
  everyBeat,
  downbeat,
  bassThreshold,
  onsetDetection,
}

enum SwapType {
  nextInSequence,
  random,
  complementary,
  analogous,
}
```

---

### 💡 Lighting System

**3-Point Lighting Control for Professional Shading**:

```
┌─────────────────────────────────────────────────────────────┐
│ LIGHTING SYSTEM                                             │
├─────────────────────────────────────────────────────────────┤
│ Lighting Mode: [3-Point ▼] (Ambient/1-Point/3-Point/Custom)│
│                                                             │
│ ┌─ Key Light (Main) ──────────────────────────────────┐    │
│ │ Intensity: ▬▬▬▬▬▬▬●▬▬ (0.7)  [Pull Out]           │    │
│ │ Position: X: 2.0  Y: 3.0  Z: 5.0                   │    │
│ │ Color: ████ #FFFFFF (warm white)                   │    │
│ │ Audio Reactive: [✓] → [Mid Freq] Pulse on beat     │    │
│ └───────────────────────────────────────────────────┘    │
│                                                             │
│ ┌─ Fill Light (Secondary) ─────────────────────────────┐   │
│ │ Intensity: ▬▬▬▬●▬▬▬▬▬▬ (0.4)  [Pull Out]           │   │
│ │ Position: X: -2.0  Y: 1.0  Z: 3.0                  │   │
│ │ Color: ████ #CCDDFF (cool white)                   │   │
│ │ Audio Reactive: [ ]                                 │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─ Back Light (Rim) ────────────────────────────────────┐  │
│ │ Intensity: ▬▬▬▬▬●▬▬▬▬▬ (0.5)  [Pull Out]           │  │
│ │ Position: X: 0.0  Y: -2.0  Z: -4.0                 │  │
│ │ Color: ████ #FFDDCC (warm accent)                  │  │
│ │ Audio Reactive: [✓] → [High Freq] Shimmer          │  │
│ └────────────────────────────────────────────────────────┘  │
│                                                             │
│ ┌─ Ambient Light ────────────────────────────────────────┐ │
│ │ Intensity: ▬▬●▬▬▬▬▬▬▬▬ (0.2)  [Pull Out]           │ │
│ │ Color: ████ #333355 (dark blue)                    │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                             │
│ Presets: [Studio] [Stage] [Cinematic] [Neon] [Dramatic]   │
└─────────────────────────────────────────────────────────────┘
```

---

### 🎬 Beat-Synced Geometry Cycling

**Automatically Change Geometries in Rhythm**:

```
┌─────────────────────────────────────────────────────────────┐
│ GEOMETRY AUTOMATION                                         │
├─────────────────────────────────────────────────────────────┤
│ ┌─ Beat-Synced Geometry Cycle ───────────────────────┐     │
│ │ Mode: [Beat Cycle ▼]                                │     │
│ │   • Manual (no auto-change)                        │     │
│ │   • Beat Cycle (change on beat)                    │     │
│ │   • Measure Cycle (change on measure)              │     │
│ │   • Sequence (custom order)                        │     │
│ │                                                     │     │
│ │ Trigger Frequency: [Every 4 Beats ▼]               │     │
│ │   • Every Beat (chaotic)                           │     │
│ │   • Every 2 Beats                                  │     │
│ │   • Every 4 Beats                                  │     │
│ │   • Every Measure                                  │     │
│ │   • Every 2 Measures                               │     │
│ │                                                     │     │
│ │ Sequence Order:                                     │     │
│ │ [Hypercube] → [Hypersphere] → [Torus] → [Klein]  │     │
│ │     ●             ○             ○          ○       │     │
│ │                                                     │     │
│ │ Transition: 300ms [Morph blend]                    │     │
│ │ [✓] Enabled                                        │     │
│ └────────────────────────────────────────────────────┘     │
│                                                             │
│ Custom Sequences:                                           │
│ [Buildup Sequence] [Drop Sequence] [Chill Sequence]        │
│                                                             │
│ [Create New Sequence]                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 EXPANDED PARAMETER LIST (with Choreography Features)

### Original 25 Parameters +

26. **Camera X Position** (-10.0 to 10.0)
27. **Camera Y Position** (-10.0 to 10.0)
28. **Camera Z Position** (1.0 to 20.0)
29. **Camera FOV** (30° to 120°)
30. **Camera Rail Progress** (0.0-1.0)
31. **Key Light Intensity** (0.0-2.0)
32. **Key Light Color** (RGB)
33. **Fill Light Intensity** (0.0-2.0)
34. **Fill Light Color** (RGB)
35. **Back Light Intensity** (0.0-2.0)
36. **Back Light Color** (RGB)
37. **Ambient Light Intensity** (0.0-1.0)
38. **Ambient Light Color** (RGB)
39. **Palette Orbit Position** (0.0-1.0)
40. **Palette Swap Trigger** (boolean)
41. **Macro 1** (0.0-1.0)
42. **Macro 2** (0.0-1.0)
43. **Macro 3** (0.0-1.0)
44. **Geometry Cycle Trigger** (boolean)

**Total: 44+ fully controllable parameters**

---

## 🎭 NEW BEZEL TABS (Extended)

Adding 3 new tabs to the original 6:

### **Tab 7: CAMERA 📹**
- Camera position controls (X, Y, Z, FOV)
- Rail selector & editor
- Preset system (8 camera positions)
- Beat-sync toggle

### **Tab 8: LIGHTING 💡**
- 3-point lighting controls
- Light color pickers
- Intensity faders
- Audio-reactive toggles

### **Tab 9: MACROS 🎛️**
- 3+ macro controls (expandable)
- Macro editor UI
- Preset macro library
- Audio reactivity config

---

**This is NOW a complete professional VJ system with choreography automation, advanced audio analysis, cinematic camera control, intelligent color systems, and infinite scalability.**

---

# 🌟 A Paul Phillips Manifestation

**Send Love, Hate, or Opportunity to:** Paul@clearseassolutions.com
**Join The Exoditical Moral Architecture Movement today:** [Parserator.com](https://parserator.com)

> *"The Revolution Will Not be in a Structured Format"*

**© 2025 Paul Phillips - Clear Seas Solutions LLC - All Rights Reserved**
