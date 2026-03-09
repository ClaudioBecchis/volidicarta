import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrashService {
  static const _keyError = 'last_crash_error';
  static const _keyStack = 'last_crash_stack';
  static const _keyTime = 'last_crash_time';

  static Future<void> save(Object error, StackTrace stack) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyError, error.toString());
      await prefs.setString(_keyStack, stack.toString());
      await prefs.setString(_keyTime, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  static Future<({String error, String stack, String time})?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final error = prefs.getString(_keyError);
      if (error == null) return null;
      return (
        error: error,
        stack: prefs.getString(_keyStack) ?? '',
        time: prefs.getString(_keyTime) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyError);
      await prefs.remove(_keyStack);
      await prefs.remove(_keyTime);
    } catch (_) {}
  }

  /// Installa i handler globali — chiamare in main() prima di runApp()
  static void install() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      save(details.exception, details.stack ?? StackTrace.empty);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      save(error, stack);
      return false; // non blocca la propagazione
    };
  }
}
