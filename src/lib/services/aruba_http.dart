import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/aruba_config.dart';

/// Client HTTP centralizzato per le chiamate ad api.php su Aruba.
/// Gestisce il token Bearer, la persistenza e la serializzazione JSON.
class ArubaHttp {
  static final ArubaHttp _instance = ArubaHttp._();
  factory ArubaHttp() => _instance;
  ArubaHttp._();

  static const _tokenKey = 'aruba_auth_token';
  static const _userIdKey = 'aruba_user_id';
  static const _usernameKey = 'aruba_username';
  static const _emailKey = 'aruba_email';
  static const _isAdminKey = 'aruba_is_admin';

  String? _token;
  String? _userId;
  String? _username;
  String? _email;
  bool _isAdmin = false;

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _token != null && _userId != null;

  /// Carica la sessione salvata da SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _username = prefs.getString(_usernameKey);
    _email = prefs.getString(_emailKey);
    _isAdmin = prefs.getBool(_isAdminKey) ?? false;

    // Verifica che il token sia ancora valido
    if (_token != null) {
      try {
        final res = await get('whoami');
        if (res == null || res['user'] == null) {
          await clearSession();
        } else {
          _userId = res['user']['id']?.toString();
          _username = res['user']['username'] as String?;
          _email = res['user']['email'] as String?;
          _isAdmin = res['user']['is_admin'] == true;
          await _saveSession();
        }
      } catch (_) {
        // Se non riesce a verificare, mantieni la sessione (offline)
      }
    }
  }

  /// Salva la sessione corrente
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) prefs.setString(_tokenKey, _token!);
    if (_userId != null) prefs.setString(_userIdKey, _userId!);
    if (_username != null) prefs.setString(_usernameKey, _username!);
    if (_email != null) prefs.setString(_emailKey, _email!);
    prefs.setBool(_isAdminKey, _isAdmin);
  }

  /// Pulisce la sessione (logout)
  Future<void> clearSession() async {
    _token = null;
    _userId = null;
    _username = null;
    _email = null;
    _isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_isAdminKey);
  }

  /// Setta la sessione dopo login/register
  Future<void> setSession({
    required String token,
    required String userId,
    required String username,
    required String email,
    bool isAdmin = false,
  }) async {
    _token = token;
    _userId = userId;
    _username = username;
    _email = email;
    _isAdmin = isAdmin;
    await _saveSession();
  }

  /// URL completo per una action
  String _url(String action, [Map<String, String>? params]) {
    final uri = Uri.parse(ArubaConfig.baseUrl).replace(
      queryParameters: {'action': action, ...?params},
    );
    return uri.toString();
  }

  /// Headers standard
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET request
  Future<dynamic> get(String action, [Map<String, String>? params]) async {
    try {
      final res = await http.get(Uri.parse(_url(action, params)), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } catch (e) {
      debugPrint('ArubaHttp.get($action) error: $e');
      return null;
    }
  }

  /// POST request
  Future<dynamic> post(String action, [Map<String, dynamic>? body, Map<String, String>? params]) async {
    try {
      final res = await http.post(
        Uri.parse(_url(action, params)),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } catch (e) {
      debugPrint('ArubaHttp.post($action) error: $e');
      return null;
    }
  }

  /// DELETE request
  Future<dynamic> delete(String action, [Map<String, String>? params]) async {
    try {
      final res = await http.delete(Uri.parse(_url(action, params)), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(res);
    } catch (e) {
      debugPrint('ArubaHttp.delete($action) error: $e');
      return null;
    }
  }

  dynamic _handleResponse(http.Response res) {
    if (res.statusCode == 204) return {'success': true};
    try {
      final data = jsonDecode(res.body);
      if (res.statusCode >= 400) {
        debugPrint('ArubaHttp error ${res.statusCode}: ${res.body}');
        return data;
      }
      return data;
    } catch (e) {
      debugPrint('ArubaHttp parse error: $e body: ${res.body}');
      return null;
    }
  }
}
