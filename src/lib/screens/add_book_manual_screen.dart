import 'package:flutter/material.dart';
import '../models/book.dart';
import 'write_review_screen.dart';

class AddBookManualScreen extends StatefulWidget {
  const AddBookManualScreen({super.key});

  @override
  State<AddBookManualScreen> createState() => _AddBookManualScreenState();
}

class _AddBookManualScreenState extends State<AddBookManualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _coverUrlCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _yearCtrl.dispose();
    _isbnCtrl.dispose();
    _pagesCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    // Genera un ID univoco basato su titolo+autore+timestamp
    final id = 'manual_${DateTime.now().millisecondsSinceEpoch}';

    final book = Book(
      id: id,
      title: _titleCtrl.text.trim(),
      authors: _authorCtrl.text.trim(),
      publisher: _publisherCtrl.text.trim().isEmpty
          ? null
          : _publisherCtrl.text.trim(),
      publishedDate: _yearCtrl.text.trim().isEmpty
          ? null
          : _yearCtrl.text.trim(),
      isbn: _isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim(),
      pageCount: int.tryParse(_pagesCtrl.text.trim()),
      coverUrl: _coverUrlCtrl.text.trim().isEmpty
          ? null
          : _coverUrlCtrl.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WriteReviewScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(title: const Text('Aggiungi Libro Manualmente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5276).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF1A5276).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF1A5276), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Inserisci i dati del libro manualmente. Solo Titolo e Autore sono obbligatori.',
                        style: TextStyle(
                            color: Colors.brown.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dati principali
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informazioni Libro',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Titolo *',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Il titolo è obbligatorio'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _authorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Autore *',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Es. Elena Ferrante',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'L\'autore è obbligatorio'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dati editoriali (opzionali)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dati Editoriali (opzionali)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _publisherCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Editore',
                          prefixIcon: Icon(Icons.business_outlined),
                          hintText: 'Es. Einaudi',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Anno',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                                hintText: 'Es. 2023',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final y = int.tryParse(v.trim());
                                if (y == null || y < 1000 || y > 2100) {
                                  return 'Anno non valido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pagesCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Pagine',
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                if (int.tryParse(v.trim()) == null) {
                                  return 'Numero non valido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _isbnCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          prefixIcon: Icon(Icons.qr_code_outlined),
                          hintText: 'Es. 9788806244118',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // URL Copertina
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Copertina (opzionale)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(
                        'Inserisci l\'URL dell\'immagine di copertina (da Google Immagini, Amazon, ecc.)',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _coverUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'URL Copertina',
                          prefixIcon: Icon(Icons.image_outlined),
                          hintText: 'https://...',
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _proceed,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Avanti — Scrivi Recensione',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Potrai aggiungere valutazione e recensione nel passo successivo',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
