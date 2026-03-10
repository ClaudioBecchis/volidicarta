import 'package:flutter/material.dart';
import '../models/forum_thread.dart';
import '../services/forum_service.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import 'forum_thread_detail_screen.dart';
import 'new_forum_thread_screen.dart';

const _allCategories = ['Tutti', 'Consigli', 'Discussioni', 'Domande', 'Off-topic'];

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<ForumThread> _threads = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String _category = 'Tutti';
  static const _pageSize = 20;
  final _service = ForumService();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
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
    try {
      final threads = await _service.fetchThreads(
          category: _category, limit: _pageSize);
      if (mounted) {
        setState(() {
          _threads = threads;
          _loading = false;
          _hasMore = threads.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    if (!mounted) return;
    setState(() => _loadingMore = true);
    try {
      final more = await _service.fetchThreads(
          category: _category, limit: _pageSize, offset: _threads.length);
      if (mounted) {
        setState(() {
          _threads.addAll(more);
          _loadingMore = false;
          _hasMore = more.length >= _pageSize;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openNewThread() async {
    final thread = await Navigator.push<ForumThread>(
      context,
      MaterialPageRoute(builder: (_) => const NewForumThreadScreen()),
    );
    if (thread != null && mounted) {
      setState(() => _threads.insert(0, thread));
    }
  }

  Future<void> _openThread(int index) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              ForumThreadDetailScreen(thread: _threads[index])),
    );
    if (deleted == true && mounted) {
      setState(() => _threads.removeAt(index));
    } else {
      // Ricarica per aggiornare replies_count
      _load();
    }
  }

  Future<void> _toggleLike(int index) async {
    final updated = await _service.toggleThreadLike(_threads[index]);
    if (mounted) setState(() => _threads[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      body: Column(
        children: [
          // Filtro categorie
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _allCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _allCategories[i];
                final selected = cat == _category;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    if (_category != cat) {
                      setState(() => _category = cat);
                      _load();
                    }
                  },
                  selectedColor: const Color(0xFF1A5276),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12),
                );
              },
            ),
          ),
          // Lista thread
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _threads.isEmpty
                    ? _emptyView()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          controller: _scrollCtrl,
                          padding:
                              const EdgeInsets.only(bottom: 80, top: 4),
                          itemCount:
                              _threads.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == _threads.length) {
                              return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            }
                            return _ThreadCard(
                              thread: _threads[i],
                              onTap: () => _openThread(i),
                              onLike: () => _toggleLike(i),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewThread,
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo thread'),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Nessun thread ancora',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Sii il primo a iniziare una discussione!',
              style: TextStyle(color: Colors.grey.shade400)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openNewThread,
            icon: const Icon(Icons.add),
            label: const Text('Crea il primo thread'),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A5276)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThreadCard extends StatelessWidget {
  final ForumThread thread;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _ThreadCard({
    required this.thread,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final isMyThread =
        thread.userId == AuthService().currentUser?.id;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: utente + categoria
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        const Color(0xFF1A5276).withValues(alpha: 0.15),
                    child: Text(
                      thread.username.isNotEmpty
                          ? thread.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Color(0xFF1A5276),
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(thread.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            if (isMyThread) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A5276)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('tu',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF1A5276))),
                              ),
                            ],
                          ],
                        ),
                        Text(_formatDate(thread.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 10)),
                      ],
                    ),
                  ),
                  _CategoryBadge(thread.category),
                ],
              ),
              const SizedBox(height: 10),
              // Titolo
              Text(thread.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              // Anteprima body
              if (thread.body != null && thread.body!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(thread.body!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13)),
              ],
              const SizedBox(height: 10),
              // Footer
              Row(
                children: [
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            thread.isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: thread.isLikedByMe
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${thread.likesCount}',
                              style: TextStyle(
                                  color: thread.isLikedByMe
                                      ? Colors.red
                                      : Colors.grey,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chat_bubble_outline,
                      size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('${thread.repliesCount}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return 'adesso';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
      if (diff.inHours < 24) return '${diff.inHours}h fa';
      if (diff.inDays < 7) return '${diff.inDays}g fa';
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge(this.category);

  Color get _color {
    switch (category) {
      case 'Consigli':
        return const Color(0xFF1A7A4A);
      case 'Discussioni':
        return const Color(0xFF1A5276);
      case 'Domande':
        return const Color(0xFF7D3C98);
      case 'Off-topic':
        return const Color(0xFF935116);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(category,
          style:
              TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
