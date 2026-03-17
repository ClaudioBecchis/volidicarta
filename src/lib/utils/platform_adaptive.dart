import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utility per design adattivo multi-piattaforma.
/// Prepara la struttura per supporto iOS/macOS futuro.
class PlatformAdaptive {
  PlatformAdaptive._();

  /// True se la piattaforma è Apple (iOS o macOS).
  static bool get isApple {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  /// True se la piattaforma è mobile (Android o iOS).
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// True se la piattaforma è desktop (Windows, macOS, Linux).
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Restituisce il nome della piattaforma per analytics/presence.
  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
