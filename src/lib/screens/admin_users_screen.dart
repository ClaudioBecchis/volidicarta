import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/app_colors.dart';

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
    if (!SupabaseConfig.isInitialized) return;
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, username, created_at, last_seen')
          .order('created_at', ascending: false);
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

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users
        .where((u) => ((u['username'] as String?) ?? '').toLowerCase().contains(q))
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
      final now = DateTime.now();
      final diff = now.difference(d);
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

    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: Text('Utenti registrati (${_users.length})'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
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
                _StatBadge(
                  icon: Icons.people_rounded,
                  label: 'Totale',
                  value: '${_users.length}',
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                _StatBadge(
                  icon: Icons.circle,
                  label: 'Online',
                  value: '$onlineCount',
                  color: const Color(0xFF2ECC71),
                ),
                const SizedBox(width: 20),
                _StatBadge(
                  icon: Icons.circle_outlined,
                  label: 'Offline',
                  value: '${_users.length - onlineCount}',
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          // Barra ricerca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cerca per username...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
                          _search.isEmpty
                              ? 'Nessun utente registrato'
                              : 'Nessun risultato per "$_search"',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 20),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final u = filtered[i];
                            final username = u['username'] as String;
                            final createdAt = u['created_at'] as String?;
                            final lastSeen = u['last_seen'] as String?;
                            final online = _isOnline(lastSeen);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF1A5276)
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Color(0xFF1A5276),
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
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .cardColor,
                                                width: 1.5),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Iscritto il ${_formatDate(createdAt)}',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (online)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2ECC71)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text('online',
                                            style: TextStyle(
                                                color: Color(0xFF1A7A4A),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      )
                                    else
                                      Text(
                                        _formatLastSeen(lastSeen),
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11),
                                      ),
                                  ],
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

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}
