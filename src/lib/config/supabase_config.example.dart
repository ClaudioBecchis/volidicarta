/// Configurazione Supabase per la community BookShelf
///
/// Istruzioni:
/// 1. Vai su https://supabase.com e crea un account gratuito
/// 2. Crea un nuovo progetto (es. "bookshelf-community")
/// 3. Vai in Project Settings > API
/// 4. Copia "Project URL" e "anon public" key qui sotto
/// 5. Vai in SQL Editor e incolla il contenuto di supabase_schema.sql
/// 6. Ricompila l'app

class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Restituisce true se le credenziali sono state configurate
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' &&
      anonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      url.startsWith('https://');
}
