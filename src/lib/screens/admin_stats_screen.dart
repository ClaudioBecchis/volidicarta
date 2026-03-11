import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/app_colors.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  bool _loading = true;
  int _totalUsers = 0;
  int _onlineUsers = 0;
  int _anonOnline = 0;
  int _newLast7d = 0;
  int _newLast30d = 0;
  List<({String day, int count})> _registrationsByDay = [];
  Map<String, int> _platforms = {};
  DateTime? _lastRefresh;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!SupabaseConfig.isInitialized || !mounted) return;
    setState(() => _loading = true);
    try {
      final c = Supabase.instance.client;

      final statsRaw = await c.rpc('get_community_stats');
      final stats = statsRaw as Map<String, dynamic>;

      final adminRaw = await c.rpc('get_admin_stats');
      final admin = adminRaw as Map<String, dynamic>;

      final regByDay = (admin['registrations_by_day'] as List? ?? [])
          .map((r) => (
                day: r['day'] as String? ?? '',
                count: (r['cnt'] as num?)?.toInt() ?? 0,
              ))
          .where((r) => r.day.isNotEmpty)
          .toList();

      final platforms = <String, int>{};
      for (final p in (admin['platforms'] as List? ?? [])) {
        final key = p['platform'] as String? ?? 'unknown';
        platforms[key] = (p['cnt'] as num?)?.toInt() ?? 0;
      }

      if (mounted) {
        setState(() {
          _totalUsers = (stats['total_users'] as num?)?.toInt() ?? 0;
          _onlineUsers = (stats['online_users'] as num?)?.toInt() ?? 0;
          _anonOnline = (stats['anon_online'] as num?)?.toInt() ?? 0;
          _newLast7d = (admin['new_last_7d'] as num?)?.toInt() ?? 0;
          _newLast30d = (admin['new_last_30d'] as num?)?.toInt() ?? 0;
          _registrationsByDay = regByDay;
          _platforms = platforms;
          _lastRefresh = DateTime.now();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('AdminStats load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: const Text('Statistiche visitatori'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_lastRefresh != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Aggiornato alle ${_lastRefresh!.hour.toString().padLeft(2, '0')}:${_lastRefresh!.minute.toString().padLeft(2, '0')}  •  auto-refresh 60s',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  _buildKpiRow(),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'Nuovi iscritti',
                    icon: Icons.person_add_outlined,
                    child: Row(
                      children: [
                        _buildMiniStat('Ultimi 7 giorni', '$_newLast7d', const Color(0xFF1A5276)),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        const SizedBox(width: 12),
                        _buildMiniStat('Ultimi 30 giorni', '$_newLast30d', Colors.teal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_registrationsByDay.isNotEmpty) ...[
                    _buildCard(
                      title: 'Iscrizioni per giorno (30 giorni)',
                      icon: Icons.bar_chart,
                      child: _BarChart(data: _registrationsByDay),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_platforms.isNotEmpty)
                    _buildCard(
                      title: 'Sessioni per piattaforma (7 giorni)',
                      icon: Icons.devices,
                      child: _PlatformBars(platforms: _platforms),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpi(
            'Totale',
            '$_totalUsers',
            Icons.people_rounded,
            const Color(0xFF1A5276),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpi(
            'Online ora',
            '$_onlineUsers',
            Icons.circle,
            const Color(0xFF2ECC71),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpi(
            'Anonimi',
            '$_anonOnline',
            Icons.person_outline,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildKpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF1A5276)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1A5276),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ── Bar chart iscrizioni ──────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<({String day, int count})> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxCount = data.map((r) => r.count).fold(0, (a, b) => a > b ? a : b);
    if (maxCount == 0) return Text('Nessuna iscrizione nel periodo', style: TextStyle(color: Colors.grey.shade500));

    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((r) {
          final pct = r.count / maxCount;
          final label = r.day.length >= 10 ? r.day.substring(5, 10) : r.day;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (r.count > 0)
                    Text(
                      '${r.count}',
                      style: const TextStyle(fontSize: 7, color: Color(0xFF1A5276), fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    height: (pct * 80).clamp(2.0, 80.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5276).withValues(alpha: r.count > 0 ? 0.75 : 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 7, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Platform breakdown ────────────────────────────────────────────────────────

class _PlatformBars extends StatelessWidget {
  final Map<String, int> platforms;
  const _PlatformBars({required this.platforms});

  static const _icons = {
    'android': Icons.android,
    'windows': Icons.window,
    'web': Icons.language,
    'ios': Icons.phone_iphone,
    'macos': Icons.laptop_mac,
    'unknown': Icons.devices_other,
  };
  static const _colors = {
    'android': Color(0xFF3DDC84),
    'windows': Color(0xFF0078D4),
    'web': Color(0xFF4285F4),
    'ios': Color(0xFF007AFF),
    'macos': Color(0xFF666666),
    'unknown': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final total = platforms.values.fold(0, (a, b) => a + b);
    final sorted = platforms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((e) {
        final pct = total > 0 ? e.value / total : 0.0;
        final color = _colors[e.key] ?? Colors.grey;
        final icon = _icons[e.key] ?? Icons.devices;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: Text(
                  e.key,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  '${e.value}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: Text(
                  '${(pct * 100).round()}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
