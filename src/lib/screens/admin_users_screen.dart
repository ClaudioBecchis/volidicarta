import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/aruba_http.dart';
import '../services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ArubaHttp().get('profiles');
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from((data as List? ?? []));
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('AdminUsers load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAdmin(Map<String, dynamic> user) async {
    final isAdmin = user['is_admin'] == true || user['is_admin'] == 1;
    final username = user['username'] as String;
    final userId = user['id'] as String;
    final myId = AuthService().currentUser?.id;

    // Conferma
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAdmin ? 'Rimuovi admin' : 'Rendi admin'),
        content: Text(
          isAdmin
              ? 'Vuoi rimuovere i permessi admin a "$username"?'
              : 'Vuoi rendere "$username" amministratore?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdmin ? Colors.red : const Color(0xFF1A5276),
            ),
            child: Text(isAdmin ? 'Rimuovi' : 'Rendi admin'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Blocca auto-demozione
    if (userId == myId && isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non puoi rimuovere il tuo stesso ruolo admin')),
      );
      return;
    }

    final res = await ArubaHttp().post('set_admin', {
      'user_id': userId,
      'is_admin': !isAdmin,
    });

    if (!mounted) return;
    if (res != null && res['error'] == null) {
      setState(() {
        final idx = _users.indexWhere((u) => u['id'] == userId);
        if (idx != -1) _users[idx] = {..._users[idx], 'is_admin': !isAdmin};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdmin
              ? '$username non è più admin'
              : '$username è ora admin'),
          backgroundColor: isAdmin ? Colors.orange : const Color(0xFF1A5276),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${res?['error'] ?? 'sconosciuto'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users
        .where((u) =>
            ((u['username'] as String?) ?? '').toLowerCase().contains(q) ||
            ((u['email'] as String?) ?? '').toLowerCase().contains(q))
        .toList();
  }

  bool _isOnline(String? lastSeen) {
    if (lastSeen == null) return false;
    final t = DateTime.tryParse(lastSeen);
    if (t == null) return false;
    return DateTime.now().toUtc().difference(t.toUtc()).inMinutes < 5;
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '—';
    }
  }

  String _formatLastSeen(String? iso) {
    if (iso == null) return 'mai';
    try {
      final d = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'adesso';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
      if (diff.inHours < 24) return '${diff.inHours}h fa';
      if (diff.inDays < 7) return '${diff.inDays}g fa';
      return _formatDate(iso);
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final onlineCount = _users.where((u) => _isOnline(u['last_seen'] as String?)).length;
    final adminCount = _users.where((u) => u['is_admin'] == true || u['is_admin'] == 1).length;

    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: Text('Utenti (${_users.length})'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // Banner stats
          Container(
            color: const Color(0xFF154360),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(child: _StatBadge(icon: Icons.people_rounded, label: 'Totale', value: '${_users.length}', color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _StatBadge(icon: Icons.circle, label: 'Online', value: '$onlineCount', color: const Color(0xFF2ECC71))),
                const SizedBox(width: 12),
                Expanded(child: _StatBadge(icon: Icons.shield_rounded, label: 'Admin', value: '$adminCount', color: const Color(0xFFF39C12))),
              ],
            ),
          ),
          // Barra ricerca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cerca username o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.chipBg(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Lista
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _search.isEmpty ? 'Nessun utente registrato' : 'Nessun risultato per "$_search"',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final u = filtered[i];
                            final username = u['username'] as String? ?? '?';
                            final email = u['email'] as String? ?? '';
                            final isAdmin = u['is_admin'] == true || u['is_admin'] == 1;
                            final online = _isOnline(u['last_seen'] as String?);
                            final isMe = u['id'] == AuthService().currentUser?.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isAdmin
                                          ? const Color(0xFFF39C12).withValues(alpha: 0.15)
                                          : const Color(0xFF1A5276).withValues(alpha: 0.12),
                                      child: Text(
                                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          color: isAdmin ? const Color(0xFFF39C12) : const Color(0xFF1A5276),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (online)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2ECC71),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Text(username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                                        child: Text('tu', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                      ),
                                    ],
                                    if (isAdmin) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.shield_rounded, size: 14, color: Color(0xFFF39C12)),
                                    ],
                                  ],
                                ),
                                subtitle: Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                trailing: IconButton(
                                  icon: Icon(
                                    isAdmin ? Icons.shield_rounded : Icons.shield_outlined,
                                    color: isAdmin ? const Color(0xFFF39C12) : Colors.grey.shade400,
                                  ),
                                  tooltip: isAdmin ? 'Rimuovi admin' : 'Rendi admin',
                                  onPressed: () => _toggleAdmin(u),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}
