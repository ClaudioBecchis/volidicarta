import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient, AuthException;
import '../config/supabase_config.dart';
import '../models/user.dart';

/// Unico sistema di autenticazione — Supabase.
/// Tutti i dati utente sono salvati sui server Supabase (cloud).
class AuthService {
  static final AuthService _instance = AuthService._();
  AuthService._();
  factory AuthService() => _instance;

  SupabaseClient? get _client =>
      SupabaseConfig.isInitialized ? Supabase.instance.client : null;

  bool _isAdmin = false;

  User? get currentUser {
    final u = _client?.auth.currentUser;
    if (u == null) return null;
    return User(
      id: u.id,
      username: u.userMetadata?['username'] as String? ?? u.email ?? '',
      email: u.email ?? '',
      isAdmin: _isAdmin,
    );
  }

  bool get isLoggedIn => _client?.auth.currentUser != null;

  /// Carica lo stato admin dal profilo Supabase — chiamare dopo il login.
  Future<void> refreshAdminStatus() async {
    final c = _client;
    final uid = c?.auth.currentUser?.id;
    if (c == null || uid == null) { _isAdmin = false; return; }
    try {
      final res = await c.from('profiles').select('is_admin').eq('id', uid).maybeSingle();
      _isAdmin = (res?['is_admin'] as bool?) ?? false;
    } catch (_) {
      _isAdmin = false;
    }
  }

  /// Chiamata all'avvio: Supabase ripristina la sessione automaticamente.
  Future<void> loadSession() async {
    // La sessione è gestita da Supabase (token persistito localmente).
    // Non serve azione manuale.
  }

  Future<String?> register(String username, String email, String password) async {
    username = username.trim();
    email = email.trim().toLowerCase();
    final c = _client;
    if (c == null) return 'Community non disponibile in questa build.';
    try {
      final res = await c.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user == null) return 'Registrazione fallita. Riprova.';
      // Crea profilo esplicitamente — non dipendere dal trigger
      try {
        await c.from('profiles').upsert({'id': res.user!.id, 'username': username});
      } catch (_) {}
      return null;
    } on AuthException catch (e) {
      return _translateError(e.message);
    } catch (e) {
      return 'Errore: ${e.toString()}';
    }
  }

  Future<String?> login(String email, String password) async {
    _isAdmin = false;
    email = email.trim();
    if (!email.contains('@')) {
      return 'Inserisci la tua email per accedere';
    }
    final c = _client;
    if (c == null) return 'Community non disponibile in questa build.';
    try {
      await c.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _translateError(e.message);
    } catch (e) {
      return 'Errore: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    _isAdmin = false;
    await _client?.auth.signOut();
  }

  String _translateError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'Email già registrata';
    }
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'Email o password errata';
    }
    if (m.contains('email not confirmed')) {
      return 'Controlla la tua email per confermare l\'account';
    }
    if (m.contains('password')) return 'Password troppo corta (min 6 caratteri)';
    if (m.contains('rate limit')) return 'Troppi tentativi. Attendi qualche minuto.';
    return msg;
  }
}
