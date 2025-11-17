import 'package:flutter/foundation.dart';

/// VIB3 Light Lab Logger
/// Production-ready logging system with different levels
class VIB3Logger {
  static const String _prefix = '[VIB3]';

  /// Debug-level logging (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr 🔍 $message');
    }
  }

  /// Info-level logging
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr ℹ️  $message');
    }
  }

  /// Warning-level logging
  static void warn(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr ⚠️  $message');
    }
  }

  /// Error-level logging (logs even in production)
  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_prefix$tagStr ❌ $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }

  /// Success-level logging
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr ✅ $message');
    }
  }
}
