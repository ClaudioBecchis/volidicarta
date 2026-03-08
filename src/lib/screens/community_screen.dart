import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/supabase_config.dart';
import '../models/public_review.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../widgets/star_rating.dart';
import 'community_review_detail_screen.dart';
import '../config/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<PublicReview> _reviews = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _username;
  static const _pageSize = 20;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isConfigured) _load();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _hasMore = true; });
    _username = AuthService().currentUser?.username;
    final r = await SupabaseService().fetchFeed(limit: _pageSize);
    if (mounted) {
      setState(() {
        _reviews = r;
        _loading = false;
        _hasMore = r.length >= _pageSize;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    if (!mounted) return;
    setState(() => _loadingMore = true);
    final r = await SupabaseService()
        .fetchFeed(limit: _pageSize, offset: _reviews.length);
    if (mounted) {
      setState(() {
        _reviews.addAll(r);
        _loadingMore = false;
        _hasMore = r.length >= _pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) return _notConfiguredView();

    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                _username ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? _emptyView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _reviews.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _reviews.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _ReviewCard(
                          review: _reviews[i], onRefresh: _load);
                    },
                  ),
                ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Nessuna recensione ancora',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Sii il primo a condividere!',
              style: TextStyle(color: Colors.grey.shade400)),
          const SizedBox(height: 24),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _notConfiguredView() {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(title: const Text('Community')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 20),
              const Text('Community non configurata',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Per attivare la community è necessario configurare\nil progetto Supabase.\n\n'
                'Segui le istruzioni nel file\nsupabase_schema.sql',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatefulWidget {
  final PublicReview review;
  final VoidCallback onRefresh;
  const _ReviewCard({required this.review, required this.onRefresh});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  late PublicReview _r;

  @override
  void initState() {
    super.initState();
    _r = widget.review;
  }

  Future<void> _toggleLike() async {
    final updated = await SupabaseService().toggleLike(_r);
    if (mounted) setState(() => _r = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  CommunityReviewDetailScreen(review: _r)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: utente + data
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        const Color(0xFF1A5276).withValues(alpha: 0.15),
                    child: Text(
                      _r.username.isNotEmpty
                          ? _r.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Color(0xFF1A5276),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_r.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(_formatDate(_r.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (_r.bookGenre != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5276).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_r.bookGenre!,
                          style: const TextStyle(
                              color: Color(0xFF1A5276), fontSize: 10)),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Libro + copertina
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_r.bookCoverUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: _r.bookCoverUrl!,
                        width: 48,
                        height: 68,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _miniPlaceholder(context),
                      ),
                    )
                  else
                    _miniPlaceholder(context),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_r.bookTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(_r.bookAuthor,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        StarRatingDisplay(rating: _r.rating, size: 16),
                      ],
                    ),
                  ),
                ],
              ),

              // Anteprima testo
              if (_r.reviewBody != null && _r.reviewBody!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _r.reviewBody!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 13),
                ),
              ],

              // Footer: like
              const SizedBox(height: 10),
              Row(
                children: [
                  InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            _r.isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: _r.isLikedByMe
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${_r.likesCount}',
                              style: TextStyle(
                                  color: _r.isLikedByMe
                                      ? Colors.red
                                      : Colors.grey,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPlaceholder(BuildContext ctx) => Container(
        width: 48,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.chipBg(ctx),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.menu_book,
            color: Color(0xFF1A5276), size: 22),
      );

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}
