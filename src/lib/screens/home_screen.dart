import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'premium_screen.dart';
import 'admin_users_screen.dart';
import 'admin_stats_screen.dart';
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
  final _myReviewsKey = GlobalKey<MyReviewsScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardTab(key: _dashboardKey, onTabChange: _onTabSelected),
      const SearchScreen(),
      MyReviewsScreen(key: _myReviewsKey),
      const WishlistScreen(),
      const StatsScreen(),
      const CommunityScreen(),
    ];
  }

  void _onTabSelected(int i) {
    setState(() => _tab = i);
    if (i == 0) _dashboardKey.currentState?._load();
    if (i == 2) _myReviewsKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Su Windows/Linux/macOS usa SEMPRE il layout desktop
    // indipendentemente dal DPI scaling che riduce i pixel logici
    final isDesktop = !kIsWeb && (
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        width > 700
    );
    final s = S.of(context);

    if (isDesktop) {
      final isExtended = width > 900;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final railBg = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F4F8);
      final user = AuthService().currentUser;

      final sw = isExtended ? 220.0 : 72.0;
      return Scaffold(
        body: Stack(
          children: [
            // ── Contenuto principale (con margine sinistro = sidebar) ─────
            Positioned(
              left: sw + 1,
              right: 0,
              top: 0,
              bottom: 0,
              child: IndexedStack(index: _tab, children: _pages),
            ),
            // ── Sidebar a TUTTA ALTEZZA (Positioned garantisce top=0,bottom=0) ──
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: sw,
              child: Material(
                color: railBg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo in cima
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
                      child: isExtended
                          ? Column(children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1A5276), Color(0xFF0D2137)],
                                  ),
                                ),
                                child: const Icon(Icons.menu_book_rounded,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(height: 8),
                              const Text('Voli di Carta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A5276))),
                            ])
                          : Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1A5276), Color(0xFF0D2137)],
                                  ),
                                ),
                                child: const Icon(Icons.menu_book_rounded,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                    ),
                    Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                    // Voci navigazione — Expanded = occupa tutto lo spazio rimasto
                    // NavigationRail con groupAlignment:-1.0 mette icone IN CIMA
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _tab,
                        onDestinationSelected: _onTabSelected,
                        extended: isExtended,
                        backgroundColor: Colors.transparent,
                        groupAlignment: -1.0,
                        minWidth: 72,
                        minExtendedWidth: 220,
                        selectedIconTheme: const IconThemeData(
                            color: Color(0xFF1A5276), size: 22),
                        unselectedIconTheme: IconThemeData(
                            color: Colors.grey.shade500, size: 22),
                        selectedLabelTextStyle: const TextStyle(
                            color: Color(0xFF1A5276),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        unselectedLabelTextStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                        indicatorColor:
                            const Color(0xFF1A5276).withValues(alpha: 0.12),
                        destinations: [
                          NavigationRailDestination(
                              icon: const Icon(Icons.home_outlined),
                              selectedIcon: const Icon(Icons.home),
                              label: Text(s.home)),
                          NavigationRailDestination(
                              icon: const Icon(Icons.search_outlined),
                              selectedIcon: const Icon(Icons.search),
                              label: Text(s.search)),
                          NavigationRailDestination(
                              icon: const Icon(Icons.rate_review_outlined),
                              selectedIcon: const Icon(Icons.rate_review),
                              label: Text(s.myReviews)),
                          NavigationRailDestination(
                              icon: const Icon(Icons.bookmark_border),
                              selectedIcon: const Icon(Icons.bookmark),
                              label: Text(s.toRead)),
                          NavigationRailDestination(
                              icon: const Icon(Icons.bar_chart_outlined),
                              selectedIcon: const Icon(Icons.bar_chart),
                              label: Text(s.stats)),
                          NavigationRailDestination(
                              icon: const Icon(Icons.people_outline),
                              selectedIcon: const Icon(Icons.people),
                              label: Text(s.community)),
                        ],
                      ),
                    ),
                    // Menu utente fisso in FONDO
                    Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                    _DesktopUserTile(
                      extended: isExtended,
                      s: s,
                      onMenuAction: (v) => _dashboardKey.currentState
                          ?._handleMenuAction(context, v, user, s),
                    ),
                  ],
                ),
              ),
            ),
            // ── Divisore verticale ────────────────────────────────────────
            Positioned(
              left: sw,
              top: 0,
              bottom: 0,
              width: 1,
              child: Container(color: Theme.of(context).dividerColor),
            ),
          ],
        ),
      );
    }

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
              label: s.home),
          NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
              label: s.search),
          NavigationDestination(
              icon: const Icon(Icons.rate_review_outlined),
              selectedIcon: const Icon(Icons.rate_review),
              label: s.myReviews),
          NavigationDestination(
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: const Icon(Icons.bookmark),
              label: s.toRead),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: s.stats),
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: s.community),
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

  Future<void> _handleMenuAction(BuildContext context, String v, dynamic user, S s) async {
    if (v == 'login') {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (mounted) setState(() {});
    } else if (v == 'settings') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } else if (v == 'about') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AboutScreen()));
    } else if (v == 'premium') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PremiumScreen()));
    } else if (v == 'admin_users') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
    } else if (v == 'admin_stats') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AdminStatsScreen()));
    } else if (v == 'logout') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(s.logout),
          content: const Text('Sei sicuro di voler uscire dall\'account community?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(s.logout)),
          ],
        ),
      );
      if (confirm != true) return;
      await AuthService().logout();
      if (mounted) setState(() {});
    }
  }

  List<PopupMenuEntry> _buildMenuItems(dynamic user, S s) => [
    PopupMenuItem(
      enabled: false,
      child: user != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user.email,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          : Text(s.guest,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    ),
    const PopupMenuDivider(),
    if (user == null) ...[
      PopupMenuItem(
        value: 'login',
        child: Row(children: [
          const Icon(Icons.login, size: 18, color: Color(0xFF1A5276)),
          const SizedBox(width: 8),
          Text(s.loginOrRegister,
              style: const TextStyle(color: Color(0xFF1A5276), fontWeight: FontWeight.w600)),
        ]),
      ),
      const PopupMenuDivider(),
    ],
    PopupMenuItem(
      value: 'settings',
      child: Row(children: [
        const Icon(Icons.settings_outlined, size: 18),
        const SizedBox(width: 8),
        Text(s.settings),
      ]),
    ),
    PopupMenuItem(
      value: 'about',
      child: Row(children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Text(s.appInfo),
      ]),
    ),
    PopupMenuItem(
      value: 'premium',
      child: Row(children: [
        ShaderMask(
          shaderCallback: (b) =>
              const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]).createShader(b),
          child: const Icon(Icons.workspace_premium_rounded, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (b) =>
              const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]).createShader(b),
          child: const Text('Premium',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    ),
    if (user != null && user.isAdmin) ...[
      PopupMenuItem(
        value: 'admin_users',
        child: Row(children: [
          const Icon(Icons.admin_panel_settings_outlined, size: 18, color: Color(0xFF1A5276)),
          const SizedBox(width: 8),
          Text(s.registeredUsers, style: const TextStyle(color: Color(0xFF1A5276))),
        ]),
      ),
      PopupMenuItem(
        value: 'admin_stats',
        child: Row(children: [
          const Icon(Icons.bar_chart, size: 18, color: Color(0xFF1A5276)),
          const SizedBox(width: 8),
          Text(s.visitorStats, style: const TextStyle(color: Color(0xFF1A5276))),
        ]),
      ),
    ],
    if (user != null) ...[
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'logout',
        child: Row(children: [
          const Icon(Icons.logout, size: 18),
          const SizedBox(width: 8),
          Text(s.logout),
        ]),
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final s = S.of(context);
    final isDesktop = (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) || MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: isDesktop
          ? null
          : AppBar(
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
                  itemBuilder: (_) => _buildMenuItems(user, s),
                  onSelected: (v) => _handleMenuAction(context, v as String, user, s),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildDashboardContent(context, user, s),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, dynamic user, S s) {
    final isWide = (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) || MediaQuery.of(context).size.width > 900;
    final actionCards = [
      _ActionCard(
        icon: Icons.add_box_outlined,
        title: s.addReadBook,
        subtitle: 'Inserisci manualmente un libro e la tua recensione',
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddBookManualScreen()));
        },
      ),
      _ActionCard(
        icon: Icons.search,
        title: s.searchOnGoogle,
        subtitle: 'Amazon, Feltrinelli, IBS e tutti gli editori',
        onTap: () => widget.onTabChange(1),
      ),
      _ActionCard(
        icon: Icons.rate_review_outlined,
        title: s.myReviewsFull,
        subtitle: 'Visualizza per autore, genere o tutti',
        onTap: () => widget.onTabChange(2),
      ),
      _ActionCard(
        icon: Icons.bookmark_border,
        title: s.toRead,
        subtitle: 'La tua lista di libri da leggere',
        onTap: () => widget.onTabChange(3),
      ),
      _ActionCard(
        icon: Icons.bar_chart,
        title: s.stats,
        subtitle: 'Vedi le statistiche delle tue letture',
        onTap: () => widget.onTabChange(4),
      ),
      _ActionCard(
        icon: Icons.people_rounded,
        title: s.community,
        subtitle: 'Scopri le recensioni di altri lettori',
        onTap: () => widget.onTabChange(5),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner principale con immagine
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.82,
                  child: Image.asset(
                    'assets/icon/banner.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF154360),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (user != null) ...[
                      const Icon(Icons.menu_book_rounded,
                          color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        _total == 0
                            ? 'Nessun libro ancora'
                            : '$_total ${_total == 1 ? 'libro letto' : 'libri letti'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                      if (_avg != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB300), size: 13),
                        const SizedBox(width: 3),
                        Text('${_avg!.toStringAsFixed(1)} medio',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                      const Spacer(),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()));
                          setState(() {});
                          _load();
                        },
                        icon: const Icon(Icons.login, size: 14),
                        label: const Text('Accedi',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1A5276),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const Spacer(),
                    ],
                    if (SupabaseConfig.isConfigured) ...[
                      const Icon(Icons.people_rounded,
                          color: Colors.white38, size: 13),
                      const SizedBox(width: 3),
                      Text('$_communityUsers iscritti',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Color(0xFF2ECC71),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 3),
                      Text('$_onlineUsers online',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(
                      'https://github.com/ClaudioBecchis/volidicarta'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF0D2137),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 5),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code, color: Colors.white38, size: 11),
                      SizedBox(width: 5),
                      Text(
                        'github.com/ClaudioBecchis/volidicarta',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Stats rapide
        if (isWide)
          Row(
            children: [
              SizedBox(
                width: 220,
                child: _QuickCard(
                  icon: Icons.menu_book_rounded,
                  label: s.booksRead,
                  value: '$_total',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 220,
                child: _QuickCard(
                  icon: Icons.star_rounded,
                  label: s.avgRating,
                  value: _avg != null ? _avg!.toStringAsFixed(1) : '-',
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 220,
                child: _QuickCard(
                  icon: Icons.bookmark_rounded,
                  label: s.toRead,
                  value: '$_wishlistCount',
                  color: AppColors.purple,
                ),
              ),
            ],
          )
        else
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
                  value: _avg != null ? _avg!.toStringAsFixed(1) : '-',
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
        // Layout a due colonne su schermi larghi
        if (isWide) ...[
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonna sinistra: ultimi libri letti
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recent.isNotEmpty) ...[
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
                    ] else
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.chipBg(context),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Nessun libro letto ancora.\nComincia aggiungendo la prima recensione!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Colonna destra: azioni rapide in griglia 2x3
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.whatToDo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      children: [
                        _GridActionCard(
                          icon: Icons.add_box_outlined,
                          title: s.addReadBook,
                          color: AppColors.primary,
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AddBookManualScreen()));
                          },
                        ),
                        _GridActionCard(
                          icon: Icons.search,
                          title: s.searchOnGoogle,
                          color: const Color(0xFF16A085),
                          onTap: () => widget.onTabChange(1),
                        ),
                        _GridActionCard(
                          icon: Icons.rate_review_outlined,
                          title: s.myReviewsFull,
                          color: const Color(0xFF8E44AD),
                          onTap: () => widget.onTabChange(2),
                        ),
                        _GridActionCard(
                          icon: Icons.bookmark_border,
                          title: s.toRead,
                          color: AppColors.purple,
                          onTap: () => widget.onTabChange(3),
                        ),
                        _GridActionCard(
                          icon: Icons.bar_chart,
                          title: s.stats,
                          color: AppColors.amber,
                          onTap: () => widget.onTabChange(4),
                        ),
                        _GridActionCard(
                          icon: Icons.people_rounded,
                          title: s.community,
                          color: const Color(0xFF2980B9),
                          onTap: () => widget.onTabChange(5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Layout mobile standard
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
                                builder: (_) => BookDetailScreen(book: book)))
                        .then((_) => _load());
                  },
                )),
          ],
          const SizedBox(height: 20),
          Text(s.whatToDo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 12),
          ...actionCards.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: c,
              )),
        ],
      ],
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

class _DesktopUserTile extends StatelessWidget {
  final bool extended;
  final S s;
  final Function(String) onMenuAction;

  const _DesktopUserTile({
    required this.extended,
    required this.s,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(8, -8),
      onSelected: onMenuAction,
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: user != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              : Text(s.guest,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        const PopupMenuDivider(),
        if (user == null)
          PopupMenuItem(
            value: 'login',
            child: Row(children: [
              const Icon(Icons.login, size: 18, color: Color(0xFF1A5276)),
              const SizedBox(width: 8),
              Text(s.loginOrRegister,
                  style: const TextStyle(
                      color: Color(0xFF1A5276), fontWeight: FontWeight.w600)),
            ]),
          ),
        PopupMenuItem(
          value: 'settings',
          child: Row(children: [
            const Icon(Icons.settings_outlined, size: 18),
            const SizedBox(width: 8),
            Text(s.settings),
          ]),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Text(s.appInfo),
          ]),
        ),
        PopupMenuItem(
          value: 'premium',
          child: Row(children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                  .createShader(b),
              child: const Icon(Icons.workspace_premium_rounded,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('Premium',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
        if (user != null && user.isAdmin) ...[
          PopupMenuItem(
            value: 'admin_users',
            child: Row(children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  size: 18, color: Color(0xFF1A5276)),
              const SizedBox(width: 8),
              Text(s.registeredUsers,
                  style: const TextStyle(color: Color(0xFF1A5276))),
            ]),
          ),
          PopupMenuItem(
            value: 'admin_stats',
            child: Row(children: [
              const Icon(Icons.bar_chart, size: 18, color: Color(0xFF1A5276)),
              const SizedBox(width: 8),
              Text(s.visitorStats,
                  style: const TextStyle(color: Color(0xFF1A5276))),
            ]),
          ),
        ],
        if (user != null) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(children: [
              const Icon(Icons.logout, size: 18),
              const SizedBox(width: 8),
              Text(s.logout),
            ]),
          ),
        ],
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: extended
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1A5276),
                    child: Text(
                      user != null
                          ? user.username.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user != null ? user.username : s.guest,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                        ),
                        Text(
                          'v1.3.33',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert,
                      size: 16, color: Colors.grey.shade400),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1A5276),
                    child: Text(
                      user != null
                          ? user.username.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
      ),
    );
  }
}

class _GridActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _GridActionCard(
      {required this.icon,
      required this.title,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
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
