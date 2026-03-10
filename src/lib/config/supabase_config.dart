import 'package:supabase_flutter/supabase_flutter.dart';

// Configurazione Supabase per la community BookShelf
//
// Istruzioni:
// 1. Vai su https://supabase.com e crea un account gratuito
// 2. Crea un nuovo progetto (es. "bookshelf-community")
// 3. Vai in Project Settings > API
// 4. Copia "Project URL" e "anon public" key qui sotto
// 5. Vai in SQL Editor e incolla il contenuto di supabase_schema.sql
// 6. Ricompila l'app

class SupabaseConfig {
  static const String url = 'https://qyoupoyikbtizcqrswkt.supabase.co';
  static const String anonKey = 'sb_publishable_YubwImp9bCpgBaSeB_-frw_e6vYWRI6';
  // Chiave JWT legacy — richiesta dalle Edge Functions
  static const String anonJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5b3Vwb3lpa2J0aXpjcXJzd2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5MTAwNzUsImV4cCI6MjA4ODQ4NjA3NX0.uMK2ji-sadDSLsnnZL18FnoenZR2evSxS9XH-IEMKvI';

  /// Restituisce true se le credenziali sono state configurate nel codice
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' &&
      anonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      url.startsWith('https://');

  /// Restituisce true solo se Supabase.initialize() è stato completato con successo.
  /// Più sicuro di isConfigured nei contesti che accedono a Supabase.instance.
  static bool get isInitialized {
    if (!isConfigured) return false;
    try {
      Supabase.instance; // lancia StateError se non inizializzato
      return true;
    } catch (_) {
      return false;
    }
  }
}
