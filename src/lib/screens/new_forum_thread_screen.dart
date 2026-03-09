import 'package:flutter/material.dart';
import '../services/forum_service.dart';
import '../models/forum_thread.dart';
import '../config/app_colors.dart';

const _categories = ['Consigli', 'Discussioni', 'Domande', 'Off-topic'];

class NewForumThreadScreen extends StatefulWidget {
  const NewForumThreadScreen({super.key});

  @override
  State<NewForumThreadScreen> createState() => _NewForumThreadScreenState();
}

class _NewForumThreadScreenState extends State<NewForumThreadScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = _categories.first;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final thread = await ForumService().createThread(
      title: _titleCtrl.text.trim(),
      category: _category,
      body: _bodyCtrl.text.trim(),
    );
    if (mounted) {
      if (thread != null) {
        Navigator.pop<ForumThread>(context, thread);
      } else {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella creazione del thread')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(
        title: const Text('Nuovo thread'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Pubblica',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Categoria
            const Text('Categoria',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final selected = cat == _category;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: const Color(0xFF1A5276),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w600 : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Titolo
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'Titolo *',
                hintText: 'Di cosa vuoi parlare?',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Inserisci un titolo' : null,
            ),
            const SizedBox(height: 16),
            // Corpo (opzionale)
            TextFormField(
              controller: _bodyCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Descrizione (opzionale)',
                hintText: 'Aggiungi dettagli al tuo thread...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Pubblica thread'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A5276),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
