import 'vib3_parameters.dart';

/// VIB3 Preset - stores all parameter values and settings
class VIB3Preset {
  String id;
  String name;
  String description;
  DateTime createdAt;
  DateTime modifiedAt;
  Map<String, num> parameters; // VIB3Parameters.name -> value
  List<String> tags;
  String? thumbnailPath;

  VIB3Preset({
    required this.id,
    required this.name,
    this.description = '',
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, num>? parameters,
    List<String>? tags,
    this.thumbnailPath,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now(),
        this.parameters = parameters ?? {},
        this.tags = tags ?? [];

  /// Create a preset from current engine state
  factory VIB3Preset.fromParameters(
    Map<VIB3Parameters, num> engineParams, {
    required String name,
    String description = '',
    List<String> tags = const [],
  }) {
    final paramMap = <String, num>{};
    engineParams.forEach((key, value) {
      paramMap[key.name] = value;
    });

    return VIB3Preset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      parameters: paramMap,
      tags: tags,
    );
  }

  /// Convert back to VIB3Parameters map
  Map<VIB3Parameters, num> toParameterMap() {
    final result = <VIB3Parameters, num>{};
    parameters.forEach((key, value) {
      try {
        final param = VIB3Parameters.values.firstWhere((p) => p.name == key);
        result[param] = value;
      } catch (e) {
        print('Unknown parameter: $key');
      }
    });
    return result;
  }

  /// Update modified timestamp
  void touch() {
    modifiedAt = DateTime.now();
  }

  /// Create a copy with updated fields
  VIB3Preset copyWith({
    String? name,
    String? description,
    Map<String, num>? parameters,
    List<String>? tags,
    String? thumbnailPath,
  }) {
    return VIB3Preset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      parameters: parameters ?? Map.from(this.parameters),
      tags: tags ?? List.from(this.tags),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'parameters': parameters,
      'tags': tags,
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Create from JSON
  factory VIB3Preset.fromJson(Map<String, dynamic> json) {
    return VIB3Preset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      parameters: Map<String, num>.from(json['parameters'] as Map),
      tags: List<String>.from(json['tags'] as List? ?? []),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }
}

/// Preset category for organization
enum PresetCategory {
  all,
  favorites,
  rotation,
  color,
  effects,
  camera,
  lighting,
  custom,
}
