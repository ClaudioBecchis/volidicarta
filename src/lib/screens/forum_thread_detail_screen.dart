import 'package:flutter/material.dart';
import '../models/forum_thread.dart';
import '../models/forum_reply.dart';
import '../services/forum_service.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';

class ForumThreadDetailScreen extends StatefulWidget {
  final ForumThread thread;
  const ForumThreadDetailScreen({super.key, required this.thread});

  @override
  State<ForumThreadDetailScreen> createState() =>
      _ForumThreadDetailScreenState();
}

class _ForumThreadDetailScreenState extends State<ForumThreadDetailScreen> {
  late ForumThread _thread;
  List<ForumReply> _replies = [];
  bool _loading = true;
  bool _sending = false;
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _service = ForumService();
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
    _myUserId = AuthService().currentUser?.id;
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final replies = await _service.fetchReplies(_thread.id);
      if (mounted) setState(() { _replies = replies; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final reply = await _service.createReply(threadId: _thread.id, body: text);
    if (mounted) {
      if (reply != null) {
        _replyCtrl.clear();
        setState(() {
          _replies.add(reply);
          _thread = _thread.copyWith(repliesCount: _thread.repliesCount + 1);
          _sending = false;
        });
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).sendError)),
        );
      }
    }
  }

  Future<void> _toggleThreadLike() async {
    final updated = await _service.toggleThreadLike(_thread);
    if (mounted) setState(() => _thread = updated);
  }

  Future<void> _toggleReplyLike(int index) async {
    final updated = await _service.toggleReplyLike(_replies[index]);
    if (mounted) setState(() => _replies[index] = updated);
  }

  Future<void> _deleteReply(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context).deleteReply),
        content: Text(S.of(context).confirmDeleteReply),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _service.deleteReply(_replies[index]);
    if (mounted) {
      setState(() {
        _replies.removeAt(index);
        _thread = _thread.copyWith(repliesCount: _thread.repliesCount - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: Text(_thread.category,
            style: const TextStyle(fontSize: 15, color: Colors.white70)),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: 1 + _replies.length,
                    itemBuilder: (_, i) {
                      if (i == 0) return _buildThreadHeader();
                      return _buildReplyCard(i - 1);
                    },
                  ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildThreadHeader() {
    final isMyThread = _thread.userId == _myUserId;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoria chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5276).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_thread.category,
                  style: const TextStyle(
                      color: Color(0xFF1A5276),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            // Titolo
            Text(_thread.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            // Corpo
            if (_thread.body != null && _thread.body!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_thread.body!,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 14, height: 1.5)),
            ],
            const SizedBox(height: 12),
            // Autore + data
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF1A5276).withValues(alpha: 0.15),
                  child: Text(
                    _thread.username.isNotEmpty
                        ? _thread.username[0].toUpperCase()
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
                      Text(_thread.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(_formatDate(_thread.createdAt),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                if (isMyThread)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(S.of(context).deleteThread),
                          content: const Text(
                              'Vuoi eliminare questo thread e tutte le risposte?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(S.of(context).cancel)),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: Text(S.of(context).delete),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await ForumService().deleteThread(_thread.id);
                        if (mounted) Navigator.pop(context, true);
                      }
                    },
                  ),
              ],
            ),
            const Divider(height: 20),
            // Like + risposte
            Row(
              children: [
                InkWell(
                  onTap: _toggleThreadLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _thread.isLikedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: _thread.isLikedByMe ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${_thread.likesCount}',
                            style: TextStyle(
                                color: _thread.isLikedByMe
                                    ? Colors.red
                                    : Colors.grey,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${_thread.repliesCount} risposte',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(int index) {
    final reply = _replies[index];
    final isMyReply = reply.userId == _myUserId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    reply.username.isNotEmpty
                        ? reply.username[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                      Text(_formatDate(reply.createdAt),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                ),
                if (isMyReply)
                  InkWell(
                    onTap: () => _deleteReply(index),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reply.body,
                style: TextStyle(
                    color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _toggleReplyLike(index),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reply.isLikedByMe
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 15,
                      color: reply.isLikedByMe ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${reply.likesCount}',
                        style: TextStyle(
                            color: reply.isLikedByMe ? Colors.red : Colors.grey,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyCtrl,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Scrivi una risposta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.chipBg(context),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _sending
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: _sendReply,
                  icon: const Icon(Icons.send_rounded),
                  color: const Color(0xFF1A5276),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1A5276).withValues(alpha: 0.1),
                  ),
                ),
        ],
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
      if (diff.inHours < 24) return '${diff.inHours} ore fa';
      if (diff.inDays < 7) return '${diff.inDays} giorni fa';
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}
