import '../models/user.dart';
import 'aruba_http.dart';

/// Servizio autenticazione — backend Aruba (PHP + MySQL).
/// Drop-in replacement di auth_service.dart (Supabase).
class AuthService {
  static final AuthService _instance = AuthService._();
  AuthService._();
  factory AuthService() => _instance;

  final _http = ArubaHttp();

  User? get currentUser {
    if (!_http.isLoggedIn) return null;
    return User(
      id: _http.userId!,
      username: _http.username ?? '',
      email: _http.email ?? '',
      isAdmin: _http.isAdmin,
    );
  }

  bool get isLoggedIn => _http.isLoggedIn;

  /// Carica sessione salvata (chiamata all'avvio)
  Future<void> loadSession() async {
    await _http.loadSession();
  }

  /// Aggiorna lo stato admin dal server
  Future<void> refreshAdminStatus() async {
    if (!_http.isLoggedIn) return;
    final res = await _http.get('is_admin');
    if (res != null && res is Map) {
      final isAdmin = res['is_admin'] == true;
      await _http.setSession(
        token: _http.token!,
        userId: _http.userId!,
        username: _http.username ?? '',
        email: _http.email ?? '',
        isAdmin: isAdmin,
      );
    }
  }

  Future<String?> register(String username, String email, String password) async {
    username = username.trim();
    email = email.trim().toLowerCase();
    final res = await _http.post('register', {
      'username': username,
      'email': email,
      'password': password,
    });
    if (res == null) return 'Errore di connessione. Riprova.';
    if (res['error'] != null) return _translateError(res['error'] as String);
    // Salva sessione
    final user = res['user'] as Map<String, dynamic>?;
    final token = res['access_token'] as String?;
    if (user != null && token != null) {
      await _http.setSession(
        token: token,
        userId: user['id'] as String,
        username: user['username'] as String? ?? username,
        email: user['email'] as String? ?? email,
      );
    }
    return null; // successo
  }

  Future<String?> login(String email, String password) async {
    email = email.trim();
    if (!email.contains('@')) {
      return 'Inserisci la tua email per accedere';
    }
    final res = await _http.post('login', {
      'email': email,
      'password': password,
    });
    if (res == null) return 'Errore di connessione. Riprova.';
    if (res['error'] != null) return _translateLoginError(res['error'] as String);
    final user = res['user'] as Map<String, dynamic>?;
    final token = res['access_token'] as String?;
    if (user != null && token != null) {
      await _http.setSession(
        token: token,
        userId: user['id'] as String,
        username: user['username'] as String? ?? '',
        email: user['email'] as String? ?? email,
      );
    }
    return null; // successo
  }

  Future<void> logout() async {
    await _http.post('logout');
    await _http.clearSession();
  }

  Future<void> resetPassword(String email) async {
    await _http.post('reset_password', {'email': email});
  }

  Future<String?> resendConfirmation(String email) async {
    final res = await _http.post('resend_confirmation', {'email': email.trim()});
    if (res == null) return 'Errore di connessione. Riprova.';
    if (res['error'] != null) {
      final e = (res['error'] as String).toLowerCase();
      if (e.contains('gia confermato')) return 'Account già confermato. Prova ad accedere.';
      if (e.contains('non trovata')) return 'Email non registrata.';
      return res['error'] as String;
    }
    return null;
  }

  String _translateLoginError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('non confermato')) return 'account_non_confermato';
    if (m.contains('troppi tentativi')) return 'Troppi tentativi. Attendi qualche minuto.';
    return 'Email o password errata';
  }

  String _translateError(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('gia in uso') || m.contains('already')) return 'Email o username già registrati';
    if (m.contains('credenziali') || m.contains('invalid')) return 'Email o password errata';
    if (m.contains('password') && m.contains('corta')) return 'Password troppo corta (min 6 caratteri)';
    if (m.contains('troppi tentativi')) return 'Troppi tentativi. Attendi qualche minuto.';
    return msg;
  }
}
