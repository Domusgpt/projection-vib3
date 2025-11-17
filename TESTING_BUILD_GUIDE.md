# VIB3 Light Lab - Testing & Build Guide

## ⚠️ Important Lifecycle & Resource Management

This guide covers critical lifecycle management fixes and testing procedures for VIB3 Light Lab.

## 🔧 Recent Fixes Applied

### 1. WebGL Canvas Lifecycle ✅
**Problem**: Parameter updates were being called in `build()` method on every rebuild, causing excessive JavaScript bridge calls.

**Solution**:
- Moved parameter updates to `Timer.periodic` (30 FPS)
- Added change detection to only send updates when parameters actually change
- Proper disposal of WebView controller and timers
- Prevents recreation with `ValueKey('webgl_canvas')`

**File**: `lib/widgets/canvas/webgl_canvas.dart`

### 2. Main Screen Update Loop ✅
**Problem**: `Future.doWhile()` loop never properly cancelled, causing memory leak.

**Solution**:
- Replaced with `Timer.periodic` for proper cancellation
- Added `dispose()` method to cancel timer
- Proper `mounted` check before updates

**File**: `lib/widgets/main_screen.dart`

### 3. Preset Manager Singleton ✅
**Problem**: Multiple Hive initializations when PresetBrowser opened repeatedly.

**Solution**:
- Implemented singleton pattern
- Only initialize Hive once
- Check if box is already open before reopening

**File**: `lib/services/preset_manager.dart`

### 4. Audio Permissions ✅
**Added**:
- Android: `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, `INTERNET`
- iOS: `NSMicrophoneUsageDescription`

**Files**:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## 🧪 Testing Checklist

### Before Testing
1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Verify dependencies**:
   ```bash
   flutter pub deps
   ```

   Should see:
   - `flutter_inappwebview: ^6.0.0`
   - `mic_stream: ^0.6.5`
   - `audio_session: ^0.1.16`
   - `fft: ^2.0.0`
   - `hive_flutter: ^1.1.0`
   - `flutter_riverpod: ^2.4.0`
   - `vector_math: ^2.1.4`

### Core Systems Testing

#### 1. WebGL Integration Test
**What to check**:
- [ ] WebGL canvas loads without errors
- [ ] Console shows "✅ VIB3 WebGL Engine ready"
- [ ] No excessive JavaScript bridge calls (check with `flutter run -v`)
- [ ] Smooth rendering (no jank)
- [ ] Parameters update when changing sliders

**How to test**:
1. Run app: `flutter run --debug`
2. Open Rotation tab
3. Change rotation sliders - should see smooth updates
4. Check console for "🧹 Disposing WebGL Canvas" when hot-reloading

#### 2. Audio Input Test
**What to check**:
- [ ] Microphone permission request appears
- [ ] Console shows "✅ Audio input started" when toggled on
- [ ] 7-band FFT visualizer shows real data (not zeros)
- [ ] Beat detection responds to music
- [ ] No crashes when toggling audio on/off multiple times

**How to test**:
1. Tap microphone icon in top bar
2. Grant permissions
3. Play music or make noise
4. Open Audio tab - verify bars move
5. Toggle audio off/on repeatedly - should not crash

#### 3. Floating Widget Test
**What to check**:
- [ ] Rotation tab pull-out button works
- [ ] Widget is draggable
- [ ] Snap-to-edge works when pin is enabled
- [ ] Minimize/maximize works
- [ ] Close button removes widget
- [ ] No widgets persist after closing all

**How to test**:
1. Open Rotation tab
2. Tap pull-out button on XY rotation
3. Drag widget around
4. Enable pin - drag near edge to test snapping
5. Minimize and maximize
6. Close widget - verify it's removed

#### 4. Preset System Test
**What to check**:
- [ ] Gallery button opens PresetBrowser (when implemented)
- [ ] 4 default presets appear on first launch
- [ ] Save current state works
- [ ] Load preset applies parameters correctly
- [ ] Delete preset works
- [ ] Search works
- [ ] No "Hive already initialized" errors when reopening

**How to test**:
1. Open Settings > Presets (TODO button)
2. Verify 4 defaults exist
3. Change some parameters
4. Save as new preset
5. Load different preset - verify parameters change
6. Close and reopen browser - should not re-initialize Hive

#### 5. Memory Leak Test
**What to check**:
- [ ] No timers running after disposal
- [ ] WebView properly disposed
- [ ] Audio input stops when toggled off
- [ ] No memory growth over time

**How to test**:
```bash
# Run with DevTools
flutter run --debug
# Then open DevTools and check Memory tab
# Perform actions, hot reload, check for memory growth
```

### Performance Testing

#### Frame Rate Test
```bash
# Enable performance overlay
flutter run --debug --enable-software-rendering
```

**Target metrics**:
- UI thread: < 16ms per frame (60 FPS)
- Raster thread: < 16ms per frame
- No red bars in performance overlay

#### JavaScript Bridge Performance
Check console for excessive calls:
```bash
flutter run -v 2>&1 | grep "WebGL:"
```

Should see updates at ~30 FPS, not 60+ FPS.

### Build Testing

#### Android Build
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing)
flutter build apk --release

# Install and test
flutter install
```

#### iOS Build
```bash
# Requires macOS and Xcode
flutter build ios --debug
flutter build ios --release

# Or run on simulator
open -a Simulator
flutter run -d <simulator-id>
```

## 🐛 Known Issues & Solutions

### Issue: WebGL not loading
**Symptoms**: Blank screen, "WebGL load error" in console

**Solutions**:
1. Check `assets/webgl/index.html` exists
2. Verify `assets/` folder in `pubspec.yaml`
3. Run `flutter clean && flutter pub get`
4. Check browser console in debug build

### Issue: Audio permission denied
**Symptoms**: Microphone toggle does nothing

**Solutions**:
1. Uninstall and reinstall app
2. Check device settings for app permissions
3. Verify `AndroidManifest.xml` and `Info.plist` have correct permissions

### Issue: Multiple Hive init errors
**Symptoms**: "Hive already initialized" errors

**Solution**: This should be fixed with singleton pattern. If still occurring, check if multiple `PresetManager()` instances are created.

### Issue: Memory leak
**Symptoms**: App slows down over time, memory usage grows

**Solutions**:
1. Check `dispose()` methods are called (add print statements)
2. Verify timers are cancelled
3. Use DevTools Memory profiler to identify leaks

## 📊 Expected Console Output

### Healthy Startup Sequence
```
✅ VIB3 WebGL Engine ready
✅ WebGL page loaded: file:///...
✅ PresetManager initialized with 4 presets
```

### When Toggling Audio
```
Audio input started: 44100 Hz, buffer size: 4096
```

### When Hot Reloading
```
🧹 Disposing WebGL Canvas
🧹 Disposing MainScreen - cancelling update timer
Audio input stopped
```

## 🔍 Debugging Tips

### Enable Verbose Logging
```bash
flutter run -v
```

### Check Widget Tree
```dart
// Add to main.dart for debugging
debugPrint('Widget tree: ${widget.toStringDeep()}');
```

### Monitor Performance
```bash
# Enable performance overlay
flutter run --enable-software-rendering

# Profile mode for accurate metrics
flutter run --profile
```

### Check Memory Usage
```bash
# Install DevTools
dart pub global activate devtools

# Run DevTools
dart pub global run devtools

# Then run app in debug mode
flutter run --debug
```

## ✅ Pre-Release Checklist

Before pushing to production:

- [ ] All tests pass
- [ ] No console errors
- [ ] No memory leaks detected
- [ ] 60 FPS maintained
- [ ] Audio input works on real devices
- [ ] WebGL renders correctly
- [ ] Presets save/load correctly
- [ ] Floating widgets work properly
- [ ] No crashes during normal usage
- [ ] App handles background/foreground properly
- [ ] Permissions requested correctly

## 📝 Additional Notes

### Resource Cleanup Order
When app is backgrounded or closed:
1. Cancel all timers first
2. Stop audio input
3. Dispose WebView
4. Close Hive boxes
5. Call super.dispose()

### Update Loop Frequencies
- Main screen providers: 60 FPS (16ms)
- WebGL parameter sync: 30 FPS (33ms)
- Audio FFT analysis: Real-time (as data arrives)
- Audio provider: 60 FPS (16ms)

### Memory Budget
Target memory usage:
- Idle: < 100 MB
- Active (audio + WebGL): < 250 MB
- Should not grow over time

## 🚀 Build Commands Reference

```bash
# Development
flutter run --debug

# Performance profiling
flutter run --profile

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release

# Install on connected device
flutter install

# Run tests
flutter test

# Analyze code
flutter analyze

# Check for pub outdated
flutter pub outdated
```

## 📚 Further Reading

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [InAppWebView Documentation](https://inappwebview.dev/)
- [Riverpod State Management](https://riverpod.dev/)
- [Hive Database](https://docs.hivedb.dev/)
