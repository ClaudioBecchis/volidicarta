import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final s = await DbHelper().getStats(uid);
    if (mounted) setState(() => _stats = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      backgroundColor: const Color(0xFFEBF5FB),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final total = _stats!['total'] as int;
    final avg = _stats!['avg'];
    final dist = _stats!['distribution'] as Map<int, int>;
    final avgStr = avg != null
        ? (avg as num).toDouble().toStringAsFixed(1)
        : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Totale libri letti
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Libri Recensiti',
                  value: '$total',
                  color: const Color(0xFF1A5276),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  label: 'Media Voti',
                  value: avgStr,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Distribuzione stelle
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribuzione Voti',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  for (int i = 5; i >= 1; i--)
                    _DistRow(
                      stars: i,
                      count: dist[i] ?? 0,
                      total: total,
                    ),
                ],
              ),
            ),
          ),
          if (total == 0) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Scrivi recensioni per vedere le statistiche',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DistRow extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _DistRow(
      {required this.stars, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          StarRatingDisplay(rating: stars, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFB300)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text('$count',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
