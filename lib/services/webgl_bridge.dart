import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/vib3_parameters.dart';

/// Bridge between Flutter and WebGL JavaScript engine
class WebGLBridge {
  final InAppWebViewController controller;

  WebGLBridge(this.controller);

  /// Update a single parameter in the WebGL engine
  Future<void> updateParameter(VIB3Parameters param, double value) async {
    final jsParamName = _getUniformName(param);
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameter('$jsParamName', $value);
      }
    ''');
  }

  /// Update multiple parameters at once (more efficient)
  Future<void> updateAllParameters(Map<VIB3Parameters, double> parameters) async {
    final jsObject = <String, dynamic>{};

    for (final entry in parameters.entries) {
      final uniformName = _getUniformName(entry.key);
      jsObject[uniformName] = entry.value;
    }

    final jsString = jsonEncode(jsObject);
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameters($jsString);
      }
    ''');
  }

  /// Update audio band levels
  Future<void> updateAudioBands(
    double sub,
    double bass,
    double lowMid,
    double mid,
    double highMid,
    double presence,
    double air,
  ) async {
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameters({
          'uAudioSub': $sub,
          'uAudioBass': $bass,
          'uAudioLowMid': $lowMid,
          'uAudioMid': $mid,
          'uAudioHighMid': $highMid,
          'uAudioPresence': $presence,
          'uAudioAir': $air
        });
      }
    ''');
  }

  /// Update camera position
  Future<void> updateCamera(double x, double y, double z, double fov) async {
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameters({
          'uCameraPosition': [$x, $y, $z],
          'uCameraFOV': $fov
        });
      }
    ''');
  }

  /// Update lighting (key, fill, back, ambient)
  Future<void> updateLighting({
    required List<double> keyColor,
    required double keyIntensity,
    required List<double> fillColor,
    required double fillIntensity,
    required List<double> backColor,
    required double backIntensity,
    required List<double> ambientColor,
    required double ambientIntensity,
  }) async {
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameters({
          'uKeyLightColor': [${keyColor[0]}, ${keyColor[1]}, ${keyColor[2]}],
          'uKeyLightIntensity': $keyIntensity,
          'uFillLightColor': [${fillColor[0]}, ${fillColor[1]}, ${fillColor[2]}],
          'uFillLightIntensity': $fillIntensity,
          'uBackLightColor': [${backColor[0]}, ${backColor[1]}, ${backColor[2]}],
          'uBackLightIntensity': $backIntensity,
          'uAmbientColor': [${ambientColor[0]}, ${ambientColor[1]}, ${ambientColor[2]}],
          'uAmbientIntensity': $ambientIntensity
        });
      }
    ''');
  }

  /// Update color palette
  Future<void> updatePalette(
    List<double> color1,
    List<double> color2,
    List<double> color3,
    List<double> color4,
  ) async {
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameters({
          'uColor1': [${color1[0]}, ${color1[1]}, ${color1[2]}],
          'uColor2': [${color2[0]}, ${color2[1]}, ${color2[2]}],
          'uColor3': [${color3[0]}, ${color3[1]}, ${color3[2]}],
          'uColor4': [${color4[0]}, ${color4[1]}, ${color4[2]}]
        });
      }
    ''');
  }

  /// Map VIB3Parameters enum to WebGL uniform name
  String _getUniformName(VIB3Parameters param) {
    switch (param) {
      // Rotation
      case VIB3Parameters.rotationXY:
        return 'uRotXY';
      case VIB3Parameters.rotationXZ:
        return 'uRotXZ';
      case VIB3Parameters.rotationYZ:
        return 'uRotYZ';
      case VIB3Parameters.rotationXW:
        return 'uRotXW';
      case VIB3Parameters.rotationYW:
        return 'uRotYW';
      case VIB3Parameters.rotationZW:
        return 'uRotZW';

      // Visual
      case VIB3Parameters.gridDensity:
        return 'uGridDensity';
      case VIB3Parameters.morphFactor:
        return 'uMorphFactor';
      case VIB3Parameters.chaos:
        return 'uChaos';
      case VIB3Parameters.speed:
        return 'uSpeed';

      // Color
      case VIB3Parameters.hue:
        return 'uHue';
      case VIB3Parameters.saturation:
        return 'uSaturation';
      case VIB3Parameters.intensity:
        return 'uIntensity';

      // Effects
      case VIB3Parameters.cardBendAmount:
        return 'uCardBendAmount';
      case VIB3Parameters.perspectiveFOV:
        return 'uPerspectiveFOV';
      case VIB3Parameters.bloom:
        return 'uBloom';
      case VIB3Parameters.chromaticAberration:
        return 'uChromaticAberration';

      // Camera
      case VIB3Parameters.cameraX:
        return 'uCameraPosition'; // Will need special handling for vec3
      case VIB3Parameters.cameraY:
        return 'uCameraPosition';
      case VIB3Parameters.cameraZ:
        return 'uCameraPosition';
      case VIB3Parameters.cameraFOV:
        return 'uCameraFOV';

      default:
        return 'uUnknown';
    }
  }
}
