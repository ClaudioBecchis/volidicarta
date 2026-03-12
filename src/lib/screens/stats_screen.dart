import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  Map<String, int> _byGenre = {};
  Map<int, int> _byYear = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    try {
      final results = await Future.wait([
        DbHelper().getStats(uid),
        DbHelper().getStatsByGenre(uid),
        DbHelper().getStatsByYear(uid),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, dynamic>;
          _byGenre = results[1] as Map<String, int>;
          _byYear = results[2] as Map<int, int>;
        });
      }
    } catch (e) {
      debugPrint('Stats load error: $e');
      if (mounted) setState(() => _stats = {'total': 0, 'avg': null, 'distribution': <int, int>{}});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) || MediaQuery.of(context).size.width > 700 ? null : AppBar(title: Text(S.of(context).stats)),
      backgroundColor: AppColors.screenBg(context),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    final s = S.of(context);
    final total = _stats!['total'] as int;
    final avg = _stats!['avg'];
    final dist = _stats!['distribution'] as Map<int, int>;
    final avgStr = avg != null
        ? (avg as num).toDouble().toStringAsFixed(1)
        : '-';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Totale libri letti
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.menu_book_rounded,
                  label: s.reviewedBooks,
                  value: '$total',
                  color: const Color(0xFF1A5276),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  label: s.avgRatingLabel,
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
                  Text(S.of(context).ratingDistribution,
                      style: const TextStyle(
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
          // Generi più letti
          if (_byGenre.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.mostReadGenres,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    for (final entry in _byGenre.entries)
                      _GenreRow(
                        genre: entry.key,
                        count: entry.value,
                        maxCount: _byGenre.values.first,
                      ),
                  ],
                ),
              ),
            ),
          ],
          // Libri per anno
          if (_byYear.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.booksByYear,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    for (final entry in _byYear.entries)
                      _YearRow(
                        year: entry.key,
                        count: entry.value,
                        maxCount: _byYear.values.reduce((a, b) => a > b ? a : b),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (total == 0) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(s.writeReviewsForStats,
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

class _GenreRow extends StatelessWidget {
  final String genre;
  final int count;
  final int maxCount;

  const _GenreRow(
      {required this.genre, required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final pct = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(genre,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1A5276)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text('$count',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _YearRow extends StatelessWidget {
  final int year;
  final int count;
  final int maxCount;

  const _YearRow(
      {required this.year, required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final pct = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text('$year',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7C3AED)),
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
