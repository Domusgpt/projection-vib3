import 'package:hive_flutter/hive_flutter.dart';
import '../models/preset.dart';
import '../models/vib3_parameters.dart';
import '../utils/logger.dart';

/// Manages preset storage and retrieval using Hive with JSON (Singleton pattern)
class PresetManager {
  static const String _boxName = 'vib3_presets';
  static PresetManager? _instance;
  static bool _isInitialized = false;

  Box? _presetsBox;

  // Private constructor for singleton
  PresetManager._();

  /// Get singleton instance
  factory PresetManager() {
    _instance ??= PresetManager._();
    return _instance!;
  }

  /// Initialize Hive and open preset box (only once)
  Future<void> init() async {
    if (_isInitialized && _presetsBox != null && _presetsBox!.isOpen) {
      VIB3Logger.debug('PresetManager already initialized', 'PresetManager');
      return;
    }

    if (!_isInitialized) {
      await Hive.initFlutter();
      _isInitialized = true;
    }

    if (_presetsBox == null || !_presetsBox!.isOpen) {
      _presetsBox = await Hive.openBox(_boxName);
      VIB3Logger.success('PresetManager initialized with ${_presetsBox!.length} presets', 'PresetManager');

      // Create default presets if box is empty
      if (_presetsBox!.isEmpty) {
        await _createDefaultPresets();
      }
    }
  }

  /// Create default factory presets
  Future<void> _createDefaultPresets() async {
    final defaults = [
      VIB3Preset(
        id: 'default_rotation',
        name: 'Gentle Rotation',
        description: 'Smooth 4D rotation across all planes',
        parameters: {
          VIB3Parameters.rotationXY.name: 0.5,
          VIB3Parameters.rotationXZ.name: 0.3,
          VIB3Parameters.rotationYZ.name: 0.4,
          VIB3Parameters.rotationXW.name: 0.2,
          VIB3Parameters.speed.name: 0.5,
        },
        tags: ['rotation', 'gentle'],
      ),
      VIB3Preset(
        id: 'default_chaos',
        name: 'Chaos Mode',
        description: 'High energy chaotic visuals',
        parameters: {
          VIB3Parameters.chaos.name: 0.9,
          VIB3Parameters.speed.name: 1.5,
          VIB3Parameters.morphFactor.name: 0.8,
          VIB3Parameters.rotationXY.name: 1.0,
          VIB3Parameters.rotationXW.name: 0.7,
        },
        tags: ['chaos', 'energetic'],
      ),
      VIB3Preset(
        id: 'default_minimal',
        name: 'Minimal Grid',
        description: 'Clean minimalist grid structure',
        parameters: {
          VIB3Parameters.gridDensity.name: 3.0,
          VIB3Parameters.chaos.name: 0.1,
          VIB3Parameters.speed.name: 0.3,
          VIB3Parameters.morphFactor.name: 0.2,
        },
        tags: ['minimal', 'grid'],
      ),
      VIB3Preset(
        id: 'default_colorful',
        name: 'Vibrant Colors',
        description: 'High saturation colorful palette',
        parameters: {
          VIB3Parameters.hue.name: 0.6,
          VIB3Parameters.saturation.name: 1.0,
          VIB3Parameters.intensity.name: 1.0,
          VIB3Parameters.bloom.name: 0.5,
        },
        tags: ['color', 'vibrant'],
      ),
    ];

    for (final preset in defaults) {
      await _presetsBox!.put(preset.id, preset.toJson());
    }
  }

  /// Save a new preset
  Future<void> savePreset(VIB3Preset preset) async {
    await _presetsBox!.put(preset.id, preset.toJson());
  }

  /// Load a preset by ID
  VIB3Preset? loadPreset(String id) {
    final json = _presetsBox!.get(id);
    if (json == null) return null;
    return VIB3Preset.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// Get all presets
  List<VIB3Preset> getAllPresets() {
    return _presetsBox!.values
        .map((json) => VIB3Preset.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Search presets by name or tags
  List<VIB3Preset> searchPresets(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllPresets().where((preset) {
      return preset.name.toLowerCase().contains(lowerQuery) ||
          preset.description.toLowerCase().contains(lowerQuery) ||
          preset.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Filter presets by tag
  List<VIB3Preset> getPresetsByTag(String tag) {
    return getAllPresets().where((preset) => preset.tags.contains(tag)).toList();
  }

  /// Delete a preset
  Future<void> deletePreset(String id) async {
    await _presetsBox!.delete(id);
  }

  /// Update an existing preset
  Future<void> updatePreset(VIB3Preset preset) async {
    preset.touch();
    await _presetsBox!.put(preset.id, preset.toJson());
  }

  /// Export preset to JSON
  Map<String, dynamic> exportPreset(VIB3Preset preset) {
    return preset.toJson();
  }

  /// Import preset from JSON
  VIB3Preset importPreset(Map<String, dynamic> json) {
    return VIB3Preset.fromJson(json);
  }

  /// Get total preset count
  int get presetCount => _presetsBox!.length;

  /// Clear all presets (dangerous!)
  Future<void> clearAllPresets() async {
    await _presetsBox!.clear();
  }

  /// Close Hive box
  Future<void> dispose() async {
    await _presetsBox?.close();
  }
}
