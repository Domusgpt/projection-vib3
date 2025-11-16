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
  // 6 Rotation Planes
  Parameter(
    key: VIB3Parameters.rotationXY,
    displayName: '4D-XY Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rotationXZ,
    displayName: '4D-XZ Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rotationYZ,
    displayName: '4D-YZ Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rotationXW,
    displayName: '4D-XW Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rotationYW,
    displayName: '4D-YW Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rotationZW,
    displayName: '4D-ZW Rotation',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),

  // Visual Parameters
  Parameter(
    key: VIB3Parameters.gridDensity,
    displayName: 'Grid Density',
    range: [1, 100],
    defaultValue: 20,
  ),
  Parameter(
    key: VIB3Parameters.morphFactor,
    displayName: 'Morph Factor',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.chaos,
    displayName: 'Chaos',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.speed,
    displayName: 'Speed',
    range: [0.0, 10.0],
    defaultValue: 1.0,
  ),

  // Color Parameters
  Parameter(
    key: VIB3Parameters.hue,
    displayName: 'Color Hue',
    range: [0, 360],
    defaultValue: 180,
  ),
  Parameter(
    key: VIB3Parameters.saturation,
    displayName: 'Saturation',
    range: [0.0, 1.0],
    defaultValue: 0.8,
  ),
  Parameter(
    key: VIB3Parameters.intensity,
    displayName: 'Intensity',
    range: [0.0, 1.0],
    defaultValue: 1.0,
  ),

  // Effects
  Parameter(
    key: VIB3Parameters.cardBend,
    displayName: 'Card Bend Amount',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.cardBendAxis,
    displayName: 'Card Bend Axis',
    range: [0.0, 6.28],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.perspectiveFOV,
    displayName: 'Perspective FOV',
    range: [30, 120],
    defaultValue: 75,
  ),
  Parameter(
    key: VIB3Parameters.bloom,
    displayName: 'Bloom',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.chromaticAberration,
    displayName: 'Chromatic Aberration',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.rgbShift,
    displayName: 'RGB Shift',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),

  // Camera
  Parameter(
    key: VIB3Parameters.cameraX,
    displayName: 'Camera X',
    range: [-10.0, 10.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.cameraY,
    displayName: 'Camera Y',
    range: [-10.0, 10.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.cameraZ,
    displayName: 'Camera Z',
    range: [-20.0, 20.0],
    defaultValue: 5.0,
  ),
  Parameter(
    key: VIB3Parameters.cameraFOV,
    displayName: 'Camera FOV',
    range: [30, 120],
    defaultValue: 75,
  ),
  Parameter(
    key: VIB3Parameters.cameraRailProgress,
    displayName: 'Camera Rail Progress',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),

  // Lighting
  Parameter(
    key: VIB3Parameters.keyLightIntensity,
    displayName: 'Key Light Intensity',
    range: [0.0, 2.0],
    defaultValue: 1.0,
  ),
  Parameter(
    key: VIB3Parameters.keyLightColor,
    displayName: 'Key Light Color',
    range: [0, 360],
    defaultValue: 0,
  ),
  Parameter(
    key: VIB3Parameters.fillLightIntensity,
    displayName: 'Fill Light Intensity',
    range: [0.0, 2.0],
    defaultValue: 0.5,
  ),
  Parameter(
    key: VIB3Parameters.fillLightColor,
    displayName: 'Fill Light Color',
    range: [0, 360],
    defaultValue: 180,
  ),
  Parameter(
    key: VIB3Parameters.backLightIntensity,
    displayName: 'Back Light Intensity',
    range: [0.0, 2.0],
    defaultValue: 0.3,
  ),
  Parameter(
    key: VIB3Parameters.backLightColor,
    displayName: 'Back Light Color',
    range: [0, 360],
    defaultValue: 240,
  ),
  Parameter(
    key: VIB3Parameters.ambientLightIntensity,
    displayName: 'Ambient Light Intensity',
    range: [0.0, 1.0],
    defaultValue: 0.2,
  ),
  Parameter(
    key: VIB3Parameters.ambientLightColor,
    displayName: 'Ambient Light Color',
    range: [0, 360],
    defaultValue: 200,
  ),

  // Advanced
  Parameter(
    key: VIB3Parameters.paletteOrbitPosition,
    displayName: 'Palette Orbit Position',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.paletteSwapTrigger,
    displayName: 'Palette Swap Trigger',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.macro1,
    displayName: 'Macro 1',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.macro2,
    displayName: 'Macro 2',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.macro3,
    displayName: 'Macro 3',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
  Parameter(
    key: VIB3Parameters.geometryCycleTrigger,
    displayName: 'Geometry Cycle Trigger',
    range: [0.0, 1.0],
    defaultValue: 0.0,
  ),
];
