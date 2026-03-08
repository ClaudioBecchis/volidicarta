import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient, AuthException;
import '../models/user.dart';

/// Unico sistema di autenticazione — Supabase.
/// Tutti i dati utente sono salvati sui server Supabase (cloud).
class AuthService {
  static final AuthService _instance = AuthService._();
  AuthService._();
  factory AuthService() => _instance;

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser {
    final u = _client.auth.currentUser;
    if (u == null) return null;
    return User(
      id: u.id,
      username: u.userMetadata?['username'] as String? ?? u.email ?? '',
      email: u.email ?? '',
    );
  }

  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Chiamata all'avvio: Supabase ripristina la sessione automaticamente.
  Future<void> loadSession() async {
    // La sessione è gestita da Supabase (token persistito localmente).
    // Non serve azione manuale.
  }

  Future<String?> register(String username, String email, String password) async {
    username = username.trim();
    email = email.trim().toLowerCase();

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user == null) return 'Registrazione fallita. Riprova.';
      // Il profilo viene creato automaticamente dal trigger su auth.users.
      // Se la conferma email è attiva, l'utente riceve una mail.
      return null;
    } on AuthException catch (e) {
      return _translateError(e.message);
    } catch (e) {
      return 'Errore: ${e.toString()}';
    }
  }

  Future<String?> login(String email, String password) async {
    email = email.trim();
    if (!email.contains('@')) {
      return 'Inserisci la tua email per accedere';
    }
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return _translateError(e.message);
    } catch (e) {
      return 'Errore: ${e.toString()}';
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
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
