// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/foundation.dart';
//
// /// Console Print Utility with Colors 🎨
// /// Use ANSI escape codes to print colorful messages in the console.
//
// class ConsoleLog {
//   static const Map<String, String> _colors = {
//     'black': '\x1B[30m',
//     'red': '\x1B[31m',
//     'green': '\x1B[32m',
//     'yellow': '\x1B[33m',
//     'blue': '\x1B[34m',
//     'magenta': '\x1B[35m',
//     'cyan': '\x1B[36m',
//     'white': '\x1B[37m',
//     'reset': '\x1B[0m',
//   };
//
//   /// General colored print
//   static void printColor(String text, {String color = 'white'}) {
//     final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
//     log('$colorCode$text${_colors['reset']}');
//   }
//
//   /// Success message (Green)
//   static void printSuccess(String message) {
//     log('${_colors['green']}✅ SUCCESS: $message${_colors['reset']}');
//   }
//
//   /// Error message (Red)
//   static void printError(String message) {
//     log('${_colors['red']}❌ ERROR: $message${_colors['reset']}');
//   }
//
//   /// Warning message (Yellow)
//   static void printWarning(String message) {
//     log('${_colors['yellow']}⚠️ WARNING: $message${_colors['reset']}');
//   }
//
//   /// Info message (Blue)
//   static void printInfo(String message) {
//     log('${_colors['blue']}ℹ️ INFO: $message${_colors['reset']}');
//   }
//
//   /// Custom tag log (e.g., [DEBUG], [API], etc.)
//   static void printTag(String tag, String message, {String color = 'cyan'}) {
//     final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
//     log('$colorCode[$tag] $message${_colors['reset']}');
//   }
//
//   /// 🧩 Pretty Print Full JSON Response with Colors (no truncation)
//   static void printJsonResponse(dynamic data, {String tag = 'API RESPONSE', String color = 'magenta'}) {
//     try {
//       final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
//       final resetCode = _colors['reset']!;
//
//       // If data is already a string, decode it first
//       dynamic jsonData = data;
//       if (data is String) {
//         try {
//           jsonData = jsonDecode(data);
//         } catch (e) {
//           // If decode fails, print as is
//           _safePrint('$colorCode========== [$tag] ==========');
//           _safePrint('$colorCode$data');
//           _safePrint('$colorCode========== [END $tag] ==========$resetCode');
//           return;
//         }
//       }
//
//       final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonData);
//
//       // Print header with color
//       _safePrint('$colorCode========== [$tag] ==========');
//
//       // Split into chunks to avoid truncation (800 chars per chunk)
//       const chunkSize = 800;
//       for (var i = 0; i < jsonStr.length; i += chunkSize) {
//         final endIndex = (i + chunkSize < jsonStr.length) ? i + chunkSize : jsonStr.length;
//         final chunk = jsonStr.substring(i, endIndex);
//
//         // Print each chunk with color codes
//         _safePrint('$colorCode$chunk');
//       }
//
//       // Print footer with color and reset
//       _safePrint('$colorCode========== [END $tag] ==========$resetCode');
//     } catch (e) {
//       printError('Error printing JSON: $e');
//     }
//   }
//
//   /// Safe print that handles long strings without truncation
//   static void _safePrint(String text) {
//     // For very long strings, break into smaller chunks
//     const int chunkSize = 1000;
//
//     if (text.length <= chunkSize) {
//       debugPrint(text);
//     } else {
//       // Split long text into chunks
//       for (var i = 0; i < text.length; i += chunkSize) {
//         final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
//         debugPrint(text.substring(i, end));
//       }
//     }
//   }
//
//   /// 📋 Print full response with colors and better formatting
//   static void printFullResponse(dynamic data, {String tag = 'FULL RESPONSE', String color = 'cyan'}) {
//     try {
//       final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
//       final resetCode = _colors['reset']!;
//
//       // If data is already a string, decode it first
//       dynamic jsonData = data;
//       if (data is String) {
//         try {
//           jsonData = jsonDecode(data);
//         } catch (e) {
//           // If decode fails, print as is
//           _safePrint('$colorCode========== [$tag] ==========');
//           _safePrint('$colorCode$data');
//           _safePrint('$colorCode========== [END] ==========');
//           _safePrint(resetCode);
//           return;
//         }
//       }
//
//       final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonData);
//
//       _safePrint('$colorCode========== [$tag] ==========');
//
//       // Print JSON line by line with color
//       final lines = jsonStr.split('\n');
//       for (final line in lines) {
//         _safePrint('$colorCode$line');
//       }
//
//       _safePrint('$colorCode========== [END] ==========');
//       _safePrint(resetCode); // Reset color at the end
//     } catch (e) {
//       printError('Error printing response: $e');
//     }
//   }
//
//   /// 🎨 Print any object with custom color (no truncation)
//   static void printObject(dynamic object, {String tag = 'OBJECT', String color = 'magenta'}) {
//     try {
//       final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
//       final resetCode = _colors['reset']!;
//
//       String content;
//       if (object is String) {
//         content = object;
//       } else {
//         content = const JsonEncoder.withIndent('  ').convert(object);
//       }
//
//       _safePrint('$colorCode========== [$tag] ==========');
//
//       // Print content line by line with color
//       final lines = content.split('\n');
//       for (final line in lines) {
//         _safePrint('$colorCode$line');
//       }
//
//       _safePrint('$colorCode========== [END $tag] ==========');
//       _safePrint(resetCode);
//     } catch (e) {
//       printError('Error printing object: $e');
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Console Print Utility with Colors 🎨
/// Use ANSI escape codes to print colorful messages in the console.

class ConsoleLog {
  // 🎛️ GLOBAL SWITCH - Isse poore app ke logs ko control karo
  static bool enableLogs = true; // true = ON, false = OFF

  static const Map<String, String> _colors = {
    'black': '\x1B[30m',
    'red': '\x1B[31m',
    'green': '\x1B[32m',
    'yellow': '\x1B[33m',
    'blue': '\x1B[34m',
    'magenta': '\x1B[35m',
    'cyan': '\x1B[36m',
    'white': '\x1B[37m',
    'reset': '\x1B[0m',
  };

  /// General colored print
  static void printColor(String text, {String color = 'yellow'}) {
    if (!enableLogs) return; // ❌ Agar OFF hai to print nahi karega

    final colorCode = _colors[color.toLowerCase()] ?? _colors['yellow']!;
    log('$colorCode$text${_colors['reset']}');
  }

  /// Success message (Green)
  static void printSuccess(String message) {
    if (!enableLogs) return;

    log('${_colors['green']}✅ SUCCESS: $message${_colors['reset']}');
  }

  /// Error message (Red)
  static void printError(String message) {
    if (!enableLogs) return;

    log('${_colors['red']}❌ ERROR: $message${_colors['reset']}');
  }

  /// Warning message (Yellow)
  static void printWarning(String message) {
    if (!enableLogs) return;

    log('${_colors['yellow']}⚠️ WARNING: $message${_colors['reset']}');
  }

  /// Info message (Blue)
  static void printInfo(String message) {
    if (!enableLogs) return;

    log('${_colors['blue']}ℹ️ INFO: $message${_colors['reset']}');
  }

  /// Custom tag log (e.g., [DEBUG], [API], etc.)
  static void printTag(String tag, String message, {String color = 'cyan'}) {
    if (!enableLogs) return;

    final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
    log('$colorCode[$tag] $message${_colors['reset']}');
  }

  /// 🧩 Pretty Print Full JSON Response with Colors (no truncation)
  static void printJsonResponse(dynamic data, {String tag = 'API RESPONSE', String color = 'magenta'}) {
    if (!enableLogs) return;

    try {
      final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
      final resetCode = _colors['reset']!;

      // If data is already a string, decode it first
      dynamic jsonData = data;
      if (data is String) {
        try {
          jsonData = jsonDecode(data);
        } catch (e) {
          // If decode fails, print as is
          _safePrint('$colorCode========== [$tag] ==========');
          _safePrint('$colorCode$data');
          _safePrint('$colorCode========== [END $tag] ==========$resetCode');
          return;
        }
      }

      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Print header with color
      _safePrint('$colorCode========== [$tag] ==========');

      // Split into chunks to avoid truncation (800 chars per chunk)
      const chunkSize = 800;
      for (var i = 0; i < jsonStr.length; i += chunkSize) {
        final endIndex = (i + chunkSize < jsonStr.length) ? i + chunkSize : jsonStr.length;
        final chunk = jsonStr.substring(i, endIndex);

        // Print each chunk with color codes
        _safePrint('$colorCode$chunk');
      }

      // Print footer with color and reset
      _safePrint('$colorCode========== [END $tag] ==========$resetCode');
    } catch (e) {
      printError('Error printing JSON: $e');
    }
  }

  /// Safe print that handles long strings without truncation
  static void _safePrint(String text) {
    if (!enableLogs) return;

    // For very long strings, break into smaller chunks
    const int chunkSize = 1000;

    if (text.length <= chunkSize) {
      debugPrint(text);
    } else {
      // Split long text into chunks
      for (var i = 0; i < text.length; i += chunkSize) {
        final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
        debugPrint(text.substring(i, end));
      }
    }
  }

  /// 📋 Print full response with colors and better formatting
  static void printFullResponse(dynamic data, {String tag = 'FULL RESPONSE', String color = 'cyan'}) {
    if (!enableLogs) return;

    try {
      final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
      final resetCode = _colors['reset']!;

      // If data is already a string, decode it first
      dynamic jsonData = data;
      if (data is String) {
        try {
          jsonData = jsonDecode(data);
        } catch (e) {
          // If decode fails, print as is
          _safePrint('$colorCode========== [$tag] ==========');
          _safePrint('$colorCode$data');
          _safePrint('$colorCode========== [END] ==========');
          _safePrint(resetCode);
          return;
        }
      }

      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonData);

      _safePrint('$colorCode========== [$tag] ==========');

      // Print JSON line by line with color
      final lines = jsonStr.split('\n');
      for (final line in lines) {
        _safePrint('$colorCode$line');
      }

      _safePrint('$colorCode========== [END] ==========');
      _safePrint(resetCode); // Reset color at the end
    } catch (e) {
      printError('Error printing response: $e');
    }
  }

  /// 🎨 Print any object with custom color (no truncation)
  static void printObject(dynamic object, {String tag = 'OBJECT', String color = 'magenta'}) {
    if (!enableLogs) return;

    try {
      final colorCode = _colors[color.toLowerCase()] ?? _colors['white']!;
      final resetCode = _colors['reset']!;

      String content;
      if (object is String) {
        content = object;
      } else {
        content = const JsonEncoder.withIndent('  ').convert(object);
      }

      _safePrint('$colorCode========== [$tag] ==========');

      // Print content line by line with color
      final lines = content.split('\n');
      for (final line in lines) {
        _safePrint('$colorCode$line');
      }

      _safePrint('$colorCode========== [END $tag] ==========');
      _safePrint(resetCode);
    } catch (e) {
      printError('Error printing object: $e');
    }
  }

  // 🎛️ UTILITY METHODS - Logs ko control karne ke liye

  /// Logs ko ON karo (Enable all logs)
  static void enableAllLogs() {
    enableLogs = true;
    log('✅ Console Logs ENABLED');
  }

  /// Logs ko OFF karo (Disable all logs)
  static void disableAllLogs() {
    log('❌ Console Logs DISABLED');
    enableLogs = false;
  }

  /// Current status check karo
  static bool areLogsEnabled() {
    return enableLogs;
  }

  /// Toggle logs (ON <-> OFF)
  static void toggleLogs() {
    enableLogs = !enableLogs;
    if (enableLogs) {
      log('✅ Console Logs ENABLED');
    } else {
      log('❌ Console Logs DISABLED');
    }
  }
}