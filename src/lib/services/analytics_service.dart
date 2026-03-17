import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio di analytics anonimi con consenso esplicito.
///
/// Traccia solo eventi aggregati (nessun dato personale):
/// - Feature più usate (ricerca, community, forum, etc.)
/// - Piattaforma e lingua
///
/// Tutti i dati sono memorizzati localmente e inviati solo
/// se l'utente ha dato il consenso GDPR.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  static const _consentKey = 'analytics_consent';
  static const _eventsKey = 'analytics_events';

  bool _consentGiven = false;
  bool get hasConsent => _consentGiven;

  /// Inizializza leggendo il consenso salvato.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _consentGiven = prefs.getBool(_consentKey) ?? false;
    } catch (e) {
      debugPrint('AnalyticsService.init error: $e');
    }
  }

  /// Imposta il consenso dell'utente.
  Future<void> setConsent(bool value) async {
    _consentGiven = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, value);
      if (!value) {
        // Se l'utente revoca il consenso, cancella tutti i dati
        await prefs.remove(_eventsKey);
      }
    } catch (e) {
      debugPrint('AnalyticsService.setConsent error: $e');
    }
  }

  /// Traccia un evento anonimo. Non fa nulla senza consenso.
  Future<void> trackEvent(String eventName, [Map<String, String>? params]) async {
    if (!_consentGiven) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList(_eventsKey) ?? [];
      final entry = '${DateTime.now().toIso8601String()}|$eventName'
          '${params != null ? '|${params.entries.map((e) => '${e.key}=${e.value}').join(',')}' : ''}';
      events.add(entry);
      // Mantieni solo gli ultimi 500 eventi
      if (events.length > 500) {
        events.removeRange(0, events.length - 500);
      }
      await prefs.setStringList(_eventsKey, events);
    } catch (e) {
      debugPrint('AnalyticsService.trackEvent error: $e');
    }
  }

  /// Restituisce il conteggio eventi per tipo (per debug/admin).
  Future<Map<String, int>> getEventCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList(_eventsKey) ?? [];
      final counts = <String, int>{};
      for (final e in events) {
        final parts = e.split('|');
        if (parts.length >= 2) {
          counts[parts[1]] = (counts[parts[1]] ?? 0) + 1;
        }
      }
      return counts;
    } catch (_) {
      return {};
    }
  }

  /// Pulisce tutti gli eventi tracciati.
  Future<void> clearEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
    } catch (_) {}
  }
}
