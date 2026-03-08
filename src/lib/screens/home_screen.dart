import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../database/db_helper.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'my_reviews_screen.dart';
import 'stats_screen.dart';
import 'add_book_manual_screen.dart';
import 'about_screen.dart';
import 'book_detail_screen.dart';
import 'community_screen.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';
import '../models/book.dart';
import '../config/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _dashboardKey = GlobalKey<_DashboardTabState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardTab(key: _dashboardKey, onTabChange: _onTabSelected),
      const SearchScreen(),
      const MyReviewsScreen(),
      const WishlistScreen(),
      const StatsScreen(),
      const CommunityScreen(),
    ];
  }

  void _onTabSelected(int i) {
    setState(() => _tab = i);
    if (i == 0) _dashboardKey.currentState?._load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
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
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Da leggere'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Statistiche'),
          NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Community'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  const _DashboardTab({super.key, required this.onTabChange});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _total = 0;
  double? _avg;
  int _wishlistCount = 0;
  List<Review> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) return;
    final results = await Future.wait([
      DbHelper().getStats(uid),
      DbHelper().getRecentReviews(uid),
      DbHelper().wishlistCount(uid),
    ]);
    if (mounted) {
      final stats = results[0] as Map<String, dynamic>;
      setState(() {
        _total = stats['total'] as int;
        _avg = stats['avg'] != null ? (stats['avg'] as num).toDouble() : null;
        _recent = results[1] as List<Review>;
        _wishlistCount = results[2] as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: const Text('Voli di Carta'),
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
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Impostazioni'),
                  ],
                ),
              ),
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
              if (v == 'settings') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              } else if (v == 'about') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              } else if (v == 'logout') {
                final nav = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Disconnetti'),
                    content: const Text(
                        'Sei sicuro di voler uscire dall\'account community?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annulla')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Disconnetti')),
                    ],
                  ),
                );
                if (confirm != true) return;
                await AuthService().logout();
                if (mounted) {
                  nav.pushReplacement(
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
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.bookmark_rounded,
                      label: 'Da leggere',
                      value: '$_wishlistCount',
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              // Ultimi libri letti
              if (_recent.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Ultimi letti',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 10),
                ..._recent.map((r) => _RecentBookTile(
                      review: r,
                      onTap: () {
                        final book = Book(
                          id: r.bookId,
                          title: r.bookTitle,
                          authors: r.bookAuthor,
                          coverUrl: r.bookCoverUrl,
                          publisher: r.bookPublisher,
                          publishedDate: r.bookYear,
                          categories: r.bookGenre,
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    BookDetailScreen(book: book)))
                            .then((_) => _load());
                      },
                    )),
              ],
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
                onTap: () => widget.onTabChange(1),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.rate_review_outlined,
                title: 'Le Mie Recensioni',
                subtitle: 'Visualizza per autore, genere o tutti',
                onTap: () => widget.onTabChange(2),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.bookmark_border,
                title: 'Da Leggere',
                subtitle: 'La tua lista di libri da leggere',
                onTap: () => widget.onTabChange(3),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.bar_chart,
                title: 'Statistiche',
                subtitle: 'Vedi le statistiche delle tue letture',
                onTap: () => widget.onTabChange(4),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.people_rounded,
                title: 'Community',
                subtitle: 'Scopri le recensioni di altri lettori',
                onTap: () => widget.onTabChange(5),
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

class _RecentBookTile extends StatelessWidget {
  final Review review;
  final VoidCallback onTap;
  const _RecentBookTile({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 40,
            height: 56,
            child: review.bookCoverUrl != null
                ? CachedNetworkImage(
                    imageUrl: review.bookCoverUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        title: Text(
          review.bookTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          review.bookAuthor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
            const SizedBox(width: 2),
            Text('${review.rating}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFD6EAF8),
        child: const Center(
            child: Icon(Icons.menu_book,
                color: Color(0xFF1A5276), size: 20)),
      );
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
          backgroundColor: const Color(0xFF1A5276).withValues(alpha: 0.1),
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
