import '../config/aruba_config.dart';

// Compatibilità: le screens importano SupabaseConfig per i check.
// Ora punta al backend Aruba.

class SupabaseConfig {
  static const String url = '';
  static const String anonKey = '';
  static const String anonJwt = '';

  /// Restituisce true se il backend Aruba è configurato
  static bool get isConfigured => ArubaConfig.isConfigured;

  /// Restituisce true — con Aruba non serve inizializzazione async
  static bool get isInitialized => ArubaConfig.isConfigured;
}
