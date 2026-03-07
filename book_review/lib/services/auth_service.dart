import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  AuthService._();
  factory AuthService() => _instance;

  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyEmail = 'user_email';

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUserId);
    if (id == null) return;
    _currentUser = User(
      id: id,
      username: prefs.getString(_keyUsername) ?? '',
      email: prefs.getString(_keyEmail) ?? '',
      passwordHash: '',
      createdAt: '',
    );
  }

  Future<String?> register(
      String username, String email, String password) async {
    username = username.trim();
    email = email.trim().toLowerCase();

    if (username.length < 3) return 'Username troppo corto (min 3 caratteri)';
    if (!RegExp(r'^[\w.]+@[\w.]+\.\w+$').hasMatch(email)) {
      return 'Email non valida';
    }
    if (password.length < 6) return 'Password troppo corta (min 6 caratteri)';

    final db = DbHelper();
    if (await db.usernameExists(username)) return 'Username già in uso';
    if (await db.emailExists(email)) return 'Email già registrata';

    final now = DateTime.now().toIso8601String();
    final user = User(
      username: username,
      email: email,
      passwordHash: _hash(password),
      createdAt: now,
    );
    final id = await db.insertUser(user);
    _currentUser = User(
      id: id,
      username: username,
      email: email,
      passwordHash: '',
      createdAt: now,
    );
    await _saveSession();
    return null;
  }

  Future<String?> login(String usernameOrEmail, String password) async {
    usernameOrEmail = usernameOrEmail.trim();
    final db = DbHelper();
    User? user;
    if (usernameOrEmail.contains('@')) {
      user = await db.getUserByEmail(usernameOrEmail.toLowerCase());
    } else {
      user = await db.getUserByUsername(usernameOrEmail);
    }
    if (user == null) return 'Utente non trovato';
    if (user.passwordHash != _hash(password)) return 'Password errata';
    _currentUser = user;
    await _saveSession();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, _currentUser!.id!);
    await prefs.setString(_keyUsername, _currentUser!.username);
    await prefs.setString(_keyEmail, _currentUser!.email);
  }
}
