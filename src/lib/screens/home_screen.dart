import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../database/db_helper.dart';
import '../config/supabase_config.dart';
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
import 'admin_users_screen.dart';
import '../models/book.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

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
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: S.of(context).home),
          NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
              label: S.of(context).search),
          NavigationDestination(
              icon: const Icon(Icons.rate_review_outlined),
              selectedIcon: const Icon(Icons.rate_review),
              label: S.of(context).myReviews),
          NavigationDestination(
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: const Icon(Icons.bookmark),
              label: S.of(context).toRead),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: S.of(context).stats),
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: S.of(context).community),
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
  int _communityUsers = 0;
  int _onlineUsers = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadCommunityStats();
  }

  Future<void> _loadCommunityStats() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final stats = await SupabaseService().getCommunityStats();
      if (mounted) {
        setState(() {
          _communityUsers = stats.totalUsers;
          _onlineUsers = stats.onlineUsers;
        });
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() {});
      return;
    }
    try {
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
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: user != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Voli di Carta',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Ciao, ${user.username}!',
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              )
            : const Text('Voli di Carta'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (_) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: user != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(user.email,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    : const Text('Ospite',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              const PopupMenuDivider(),
              if (user == null) ...[
                const PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login, size: 18, color: Color(0xFF1A5276)),
                      SizedBox(width: 8),
                      Text('Accedi / Registrati',
                          style: TextStyle(color: Color(0xFF1A5276), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
              ],
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
              if (user != null && user.username.toLowerCase() == 'claudio')
                const PopupMenuItem(
                  value: 'admin_users',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined,
                          size: 18, color: Color(0xFF1A5276)),
                      SizedBox(width: 8),
                      Text('Utenti registrati',
                          style: TextStyle(color: Color(0xFF1A5276))),
                    ],
                  ),
                ),
              if (user != null) ...[
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
            ],
            onSelected: (v) async {
              if (v == 'login') {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                setState(() {});
              } else if (v == 'settings') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              } else if (v == 'about') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              } else if (v == 'admin_users') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
              } else if (v == 'logout') {
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
                if (mounted) setState(() {});
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
              // Banner principale
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5276), Color(0xFF2471A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Corpo principale
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              color: Colors.white, size: 44),
                          const SizedBox(width: 16),
                          Expanded(
                            child: user != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _total == 0
                                            ? 'Inizia a leggere!'
                                            : '$_total ${_total == 1 ? 'libro letto' : 'libri letti'}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _avg != null
                                            ? 'Voto medio: ${_avg!.toStringAsFixed(1)} ★'
                                            : 'Aggiungi la tua prima recensione',
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Voli di Carta',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Le tue recensioni, sempre con te',
                                        style: TextStyle(
                                            color: Colors.white70, fontSize: 13),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (_) => const LoginScreen()));
                                          setState(() {});
                                          _load();
                                        },
                                        icon: const Icon(Icons.login, size: 15),
                                        label: const Text('Accedi / Registrati',
                                            style: TextStyle(fontSize: 13)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF1A5276),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // Striscia community stats
                    if (_communityUsers > 0 || _onlineUsers > 0)
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF154360),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.people_rounded,
                                color: Colors.white54, size: 13),
                            const SizedBox(width: 4),
                            Text('$_communityUsers iscritti',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11)),
                            const SizedBox(width: 12),
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF2ECC71),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('$_onlineUsers online ora',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11)),
                          ],
                        ),
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
                      label: s.booksRead,
                      value: '$_total',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.star_rounded,
                      label: s.avgRating,
                      value: _avg != null
                          ? _avg!.toStringAsFixed(1)
                          : '-',
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.bookmark_rounded,
                      label: s.toRead,
                      value: '$_wishlistCount',
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              // Ultimi libri letti
              if (_recent.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(s.lastRead,
                    style: const TextStyle(
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
              Text(s.whatToDo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.add_box_outlined,
                title: s.addReadBook,
                subtitle: 'Inserisci manualmente un libro e la tua recensione',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AddBookManualScreen()));
                },
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.search,
                title: s.searchOnGoogle,
                subtitle: 'Amazon, Feltrinelli, IBS e tutti gli editori',
                onTap: () => widget.onTabChange(1),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.rate_review_outlined,
                title: s.myReviewsFull,
                subtitle: 'Visualizza per autore, genere o tutti',
                onTap: () => widget.onTabChange(2),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.bookmark_border,
                title: s.toRead,
                subtitle: 'La tua lista di libri da leggere',
                onTap: () => widget.onTabChange(3),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.bar_chart,
                title: s.stats,
                subtitle: 'Vedi le statistiche delle tue letture',
                onTap: () => widget.onTabChange(4),
              ),
              const SizedBox(height: 8),
              _ActionCard(
                icon: Icons.people_rounded,
                title: s.community,
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
                    errorWidget: (_, __, ___) => _placeholder(context),
                  )
                : _placeholder(context),
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

  Widget _placeholder(BuildContext ctx) => Container(
        color: AppColors.chipBg(ctx),
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
