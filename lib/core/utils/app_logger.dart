import 'dart:convert';
import 'dart:developer' as dev;

class AppLogger {
  static void info(String message, {Map<String, Object?>? data}) {
    _log(message, level: 800, data: data);
  }

  static void warn(String message, {Map<String, Object?>? data}) {
    _log(message, level: 900, data: data);
  }

  static void error(
    String message,
    Object error,
    StackTrace st, {
    Map<String, Object?>? data,
  }) {
    _log(
      message,
      level: 1000,
      error: error,
      stackTrace: st,
      data: data,
    );
  }

  static void _log(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    final payload = <String, Object?>{
      ...?data,
      if (error != null) 'error': error.toString(),
    };
    dev.log(
      payload.isEmpty ? message : '$message | ${jsonEncode(payload)}',
      name: 'lapiNia',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
