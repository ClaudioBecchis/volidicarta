import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../models/public_review.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';
import '../database/db_helper.dart';
import '../widgets/star_rating.dart';

class WriteReviewScreen extends StatefulWidget {
  final Book book;
  final Review? existing;

  const WriteReviewScreen({super.key, required this.book, this.existing});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  int _rating = 0;
  String? _startDate;
  String? _endDate;
  String? _genre;
  bool _saving = false;
  bool _sharePublic = false;

  static const _genres = [
    'Narrativa', 'Romanzo', 'Giallo / Thriller', 'Fantasy', 'Fantascienza',
    'Horror', 'Storico', 'Biografico', 'Saggistica', 'Poesia',
    'Fumetto / Graphic Novel', 'Bambini / Ragazzi', 'Scolastico',
    'Informatica / Tecnologia', 'Economia / Finanza', 'Psicologia',
    'Filosofia', 'Arte', 'Cucina', 'Sport', 'Altro',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _rating = e.rating;
      _titleCtrl.text = e.reviewTitle ?? '';
      _bodyCtrl.text = e.reviewBody ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _genre = e.bookGenre;
    } else {
      // Auto-popola il genere dalle categorie Google Books
      final cats = widget.book.categories;
      if (cats != null && cats.isNotEmpty) {
        _genre = cats.split(',').first.trim();
      }
    }
  }

  // Formato ISO 8601 per storage interno e Supabase
  String _toIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Formato dd/MM/yyyy solo per la UI
  String _displayDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso; // fallback per date già in formato vecchio
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('it', 'IT'),
      helpText: 'Data inizio lettura',
    );
    if (d != null) setState(() => _startDate = _toIso(d));
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('it', 'IT'),
      helpText: 'Data fine lettura',
    );
    if (d != null) setState(() => _endDate = _toIso(d));
  }

  Future<void> _save() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona almeno 1 stella')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    // BUG-R: valida che endDate non sia precedente a startDate
    if (_startDate != null && _endDate != null &&
        _endDate!.compareTo(_startDate!) < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).endDateBeforeStart)));
      return;
    }
    // BUG-N: null check su sessione utente
    final uid = AuthService().currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).sessionExpired)));
      return;
    }
    setState(() => _saving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final book = widget.book;

      Review review;
      if (widget.existing != null) {
        review = widget.existing!.copyWith(
          rating: _rating,
          reviewTitle: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
          reviewBody: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          bookGenre: _genre,
        );
        await DbHelper().updateReview(review);
      } else {
        review = Review(
          userId: uid,
          bookId: book.id,
          bookTitle: book.title,
          bookAuthor: book.authors,
          bookCoverUrl: book.coverUrl,
          bookPublisher: book.publisher,
          bookYear: book.publishedDate != null && book.publishedDate!.length >= 4
              ? book.publishedDate!.substring(0, 4)
              : book.publishedDate,
          bookGenre: _genre,
          rating: _rating,
          reviewTitle: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
          reviewBody: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          createdAt: now,
          updatedAt: now,
        );
        await DbHelper().insertReview(review);
      }

      final supaUid = SupabaseService().currentUser?.id;
      if (_sharePublic && SupabaseConfig.isConfigured && SupabaseService().isLoggedIn && supaUid != null) {
        final pub = PublicReview(
          id: '',
          userId: supaUid,
          username: SupabaseService().currentUsername ?? 'Utente',
          bookId: review.bookId,
          bookTitle: review.bookTitle,
          bookAuthor: review.bookAuthor,
          bookCoverUrl: review.bookCoverUrl,
          bookPublisher: review.bookPublisher,
          bookYear: review.bookYear,
          bookGenre: review.bookGenre,
          rating: review.rating,
          reviewTitle: review.reviewTitle,
          reviewBody: review.reviewBody,
          readDate: review.endDate,
          createdAt: review.createdAt ?? DateTime.now().toIso8601String(),
        );
        await SupabaseService().publishReview(pub);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: Text(isEdit ? s.editReview : s.writeReview),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(s.save,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Libro info
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.menu_book,
                      color: Color(0xFF1A5276), size: 32),
                  title: Text(widget.book.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(widget.book.authors,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 16),
              // Valutazione
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Valutazione *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Center(
                        child: StarRatingPicker(
                          rating: _rating,
                          onRatingChanged: (r) => setState(() => _rating = r),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _rating == 0
                              ? 'Tocca le stelle per valutare'
                              : [
                                  '', 'Pessimo', 'Scarso',
                                  'Nella media', 'Buono', 'Eccellente'
                                ][_rating],
                          style: TextStyle(
                              color: _rating == 0
                                  ? Colors.grey
                                  : const Color(0xFFFFB300),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Titolo recensione
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Titolo recensione (opzionale)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Es. Un capolavoro assoluto',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 100,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Testo recensione
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('La tua recensione (opzionale)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bodyCtrl,
                        maxLines: 6,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          hintText: 'Scrivi il tuo pensiero sul libro...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Genere / Tipo
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Genere / Tipo (opzionale)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _genres.contains(_genre) ? _genre : null,
                        hint: Text(S.of(context).selectGenre),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _genres
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _genre = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Data inizio lettura
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_outline,
                      color: Color(0xFF1A5276)),
                  title: const Text('Inizio lettura (opzionale)'),
                  subtitle: Text(_startDate != null ? _displayDate(_startDate!) : 'Non specificata'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_startDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _startDate = null),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: _pickStartDate,
                ),
              ),
              const SizedBox(height: 8),
              // Data fine lettura
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.stop_circle_outlined,
                      color: Color(0xFF1A5276)),
                  title: const Text('Fine lettura (opzionale)'),
                  subtitle: Text(_endDate != null ? _displayDate(_endDate!) : 'Non specificata'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _endDate = null),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: _pickEndDate,
                ),
              ),
              // Condividi nella community
              if (SupabaseConfig.isConfigured) ...[
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.people_rounded,
                        color: Color(0xFF1A5276)),
                    title: Text(s.sharedInCommunity),
                    subtitle: Text(
                      SupabaseService().isLoggedIn
                          ? 'La recensione sarà visibile a tutti'
                          : 'Accedi alla community per condividere',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _sharePublic && SupabaseService().isLoggedIn,
                    onChanged: SupabaseService().isLoggedIn
                        ? (v) => setState(() => _sharePublic = v)
                        : null,
                    activeThumbColor: const Color(0xFF1A5276),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEdit ? s.updateReview : s.saveReview,
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
