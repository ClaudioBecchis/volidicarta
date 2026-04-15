import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'aruba_http.dart';

class AdminNotificationService {
  static const _key = 'admin_last_checked';

  /// Controlla nuove registrazioni e mostra popup se necessario.
  /// Va chiamato quando l'admin apre l'app o torna alla home.
  static Future<void> checkNewRegistrations(BuildContext context) async {
    if (!AuthService().isLoggedIn) return;
    if (!(AuthService().currentUser?.isAdmin ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final lastChecked = prefs.getString(_key) ?? '2000-01-01 00:00:00';

    final res = await ArubaHttp().post('new_registrations', {'since': lastChecked});
    if (res == null || res['count'] == 0) {
      // Aggiorna comunque il timestamp
      await prefs.setString(_key, _now());
      return;
    }

    await prefs.setString(_key, _now());

    final users = List<Map<String, dynamic>>.from(res['users'] ?? []);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add, color: Color(0xFF1A5276)),
            const SizedBox(width: 8),
            Text('${res['count']} nuov${res['count'] == 1 ? 'a registrazione' : 'e registrazioni'}'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(
              dense: true,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1A5276),
                radius: 16,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              title: Text(users[i]['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(users[i]['email'] ?? '', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1A5276))),
          ),
        ],
      ),
    );
  }

  static String _now() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} '
        '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}';
  }
}
