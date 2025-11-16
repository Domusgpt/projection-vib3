import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/vib3_parameters.dart';

/// Bridge between Flutter and WebGL JavaScript engine
class WebGLBridge {
  final InAppWebViewController controller;

  WebGLBridge(this.controller);

  /// Update a single parameter in the WebGL engine
  Future<void> updateParameter(VIB3Parameter param, double value) async {
    final jsParamName = _getUniformName(param);
    await controller.evaluateJavascript(source: '''
      if (window.vib3Engine) {
        window.vib3Engine.updateParameter('$jsParamName', $value);
      }
    ''');
  }

  /// Update multiple parameters at once (more efficient)
  Future<void> updateAllParameters(Map<VIB3Parameter, double> parameters) async {
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

  /// Map VIB3Parameter enum to WebGL uniform name
  String _getUniformName(VIB3Parameter param) {
    switch (param) {
      // Rotation
      case VIB3Parameter.rotationXY:
        return 'uRotXY';
      case VIB3Parameter.rotationXZ:
        return 'uRotXZ';
      case VIB3Parameter.rotationYZ:
        return 'uRotYZ';
      case VIB3Parameter.rotationXW:
        return 'uRotXW';
      case VIB3Parameter.rotationYW:
        return 'uRotYW';
      case VIB3Parameter.rotationZW:
        return 'uRotZW';

      // Visual
      case VIB3Parameter.gridDensity:
        return 'uGridDensity';
      case VIB3Parameter.morphFactor:
        return 'uMorphFactor';
      case VIB3Parameter.chaos:
        return 'uChaos';
      case VIB3Parameter.speed:
        return 'uSpeed';

      // Color
      case VIB3Parameter.hue:
        return 'uHue';
      case VIB3Parameter.saturation:
        return 'uSaturation';
      case VIB3Parameter.intensity:
        return 'uIntensity';

      // Effects
      case VIB3Parameter.cardBendAmount:
        return 'uCardBendAmount';
      case VIB3Parameter.perspectiveFOV:
        return 'uPerspectiveFOV';
      case VIB3Parameter.bloom:
        return 'uBloom';
      case VIB3Parameter.chromaticAberration:
        return 'uChromaticAberration';

      // Camera
      case VIB3Parameter.cameraX:
        return 'uCameraPosition'; // Will need special handling for vec3
      case VIB3Parameter.cameraY:
        return 'uCameraPosition';
      case VIB3Parameter.cameraZ:
        return 'uCameraPosition';
      case VIB3Parameter.cameraFOV:
        return 'uCameraFOV';

      default:
        return 'uUnknown';
    }
  }
}
