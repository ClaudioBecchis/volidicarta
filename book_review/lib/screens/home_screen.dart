import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'my_reviews_screen.dart';
import 'stats_screen.dart';
import 'add_book_manual_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _pages = const [
    _DashboardTab(),
    SearchScreen(),
    MyReviewsScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Cerca'),
          NavigationDestination(
              icon: Icon(Icons.rate_review_outlined),
              selectedIcon: Icon(Icons.rate_review),
              label: 'Recensioni'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Statistiche'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _total = 0;
  double? _avg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final stats = await DbHelper().getStats(uid);
    if (mounted) {
      setState(() {
        _total = stats['total'];
        _avg = stats['avg'] != null ? (stats['avg'] as double) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(
        title: const Text('BookShelf'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (_) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.username ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Info App'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Disconnetti'),
                  ],
                ),
              ),
            ],
            onSelected: (v) async {
              if (v == 'about') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              } else if (v == 'logout') {
                await AuthService().logout();
                if (mounted) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Benvenuto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5276), Color(0xFF2471A3)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Ciao, ${user?.username ?? ''}!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _total == 0
                          ? 'Inizia a recensire i tuoi libri preferiti'
                          : 'Hai recensito $_total ${_total == 1 ? 'libro' : 'libri'}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stats rapide
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Libri letti',
                      value: '$_total',
                      color: const Color(0xFF1A5276),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.star_rounded,
                      label: 'Media voti',
                      value: _avg != null
                          ? _avg!.toStringAsFixed(1)
                          : '-',
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Azioni rapide
              const Text('Cosa vuoi fare?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.add_box_outlined,
                title: 'Aggiungi Libro Letto',
                subtitle: 'Inserisci manualmente un libro e la tua recensione',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AddBookManualScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.search,
                title: 'Cerca su Google Books',
                subtitle: 'Amazon, Feltrinelli, IBS e tutti gli editori',
                onTap: () {
                  final state = context
                      .findAncestorStateOfType<_HomeScreenState>();
                  state?.setState(() => state._tab = 1);
                },
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.rate_review_outlined,
                title: 'Le Mie Recensioni',
                subtitle: 'Visualizza per autore, genere o tutti',
                onTap: () {
                  final state = context
                      .findAncestorStateOfType<_HomeScreenState>();
                  state?.setState(() => state._tab = 2);
                },
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.bar_chart,
                title: 'Statistiche',
                subtitle: 'Vedi le statistiche delle tue letture',
                onTap: () {
                  final state = context
                      .findAncestorStateOfType<_HomeScreenState>();
                  state?.setState(() => state._tab = 3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A5276).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF1A5276)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
