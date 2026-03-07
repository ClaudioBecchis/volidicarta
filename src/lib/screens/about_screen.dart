import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _currentVersion = '1.0.0';
  bool _checking = false;
  String? _updateMessage;
  bool _hasUpdate = false;

  Future<void> _checkUpdates() async {
    setState(() { _checking = true; _updateMessage = null; _hasUpdate = false; });
    try {
      final uri = Uri.parse(
          'https://qyoupoyikbtizcqrswkt.supabase.co/rest/v1/app_version?select=version,release_notes&order=id.desc&limit=1');
      final res = await http.get(uri, headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5b3Vwb3lpa2J0aXpjcXJzd2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0MTE5MTIsImV4cCI6MjA1Njk4NzkxMn0.Q_6GiJ_2-VoYSHCqAzLT8BrFl09HvlezZkD3XPJZ_UU',
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final latest = data.first['version'] as String;
          final notes = data.first['release_notes'] as String? ?? '';
          if (latest != _currentVersion) {
            setState(() {
              _hasUpdate = true;
              _updateMessage = 'Nuova versione disponibile: $latest\n\n$notes';
            });
          } else {
            setState(() => _updateMessage = 'Sei già alla versione più recente ($latest).');
          }
        }
      } else {
        setState(() => _updateMessage = 'Impossibile verificare gli aggiornamenti.');
      }
    } catch (_) {
      setState(() => _updateMessage = 'Errore di rete. Controlla la connessione.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(title: const Text('Info App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icona app
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A5276),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A5276).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      size: 56, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BookShelf',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5276),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Le tue recensioni, sempre con te',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A5276).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Versione $_currentVersion',
                    style: TextStyle(
                        color: Color(0xFF1A5276),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                // Controlla aggiornamenti
                OutlinedButton.icon(
                  onPressed: _checking ? null : _checkUpdates,
                  icon: _checking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.system_update_alt_outlined),
                  label: Text(_checking ? 'Controllo...' : 'Controlla Aggiornamenti'),
                ),
                if (_updateMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hasUpdate
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _hasUpdate
                              ? Colors.green.shade300
                              : Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _hasUpdate ? Icons.new_releases_outlined : Icons.check_circle_outline,
                          color: _hasUpdate ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_updateMessage!,
                              style: TextStyle(
                                  color: _hasUpdate
                                      ? Colors.green.shade800
                                      : Colors.grey.shade700,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                // Divider
                const Divider(),
                const SizedBox(height: 24),
                // Firma
                const Text(
                  'Sviluppato da',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Claudio Becchis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5276),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.language,
                        size: 16, color: Color(0xFF1A5276)),
                    const SizedBox(width: 6),
                    Text(
                      'polariscore.it',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                // Funzionalità
                _FeatureRow(
                    icon: Icons.search,
                    text: 'Ricerca su Google Books (Amazon, Feltrinelli, IBS...)'),
                _FeatureRow(
                    icon: Icons.star_rounded,
                    text: 'Recensioni con valutazione a stelle'),
                _FeatureRow(
                    icon: Icons.category_outlined,
                    text: 'Organizzazione per Autore e Genere'),
                _FeatureRow(
                    icon: Icons.bar_chart,
                    text: 'Statistiche di lettura personali'),
                _FeatureRow(
                    icon: Icons.lock_outline,
                    text: 'Dati salvati localmente sul dispositivo'),
                const SizedBox(height: 32),
                Text(
                  '© ${DateTime.now().year} Claudio Becchis · polariscore.it',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A5276), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
