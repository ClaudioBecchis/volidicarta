import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../config/supabase_config.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _currentVersion = '1.0.0';
  bool _checking = false;
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _updateMessage;
  bool _hasUpdate = false;
  String? _latestVersion;
  String? _downloadUrl;

  Future<void> _checkUpdates() async {
    setState(() { _checking = true; _updateMessage = null; _hasUpdate = false; });
    try {
      final uri = Uri.parse(
          '${SupabaseConfig.url}/rest/v1/app_version?select=version,release_notes,download_url&order=id.desc&limit=1');
      final res = await http.get(uri, headers: {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final latest = data.first['version'] as String;
          final notes = data.first['release_notes'] as String? ?? '';
          _downloadUrl = data.first['download_url'] as String?;
          _latestVersion = latest;
          if (latest != _currentVersion) {
            setState(() {
              _hasUpdate = true;
              _updateMessage = 'Nuova versione disponibile: v$latest\n\n$notes';
            });
          } else {
            setState(() => _updateMessage = 'Sei già alla versione più recente (v$latest).');
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

  Future<void> _downloadAndInstall() async {
    if (_downloadUrl == null) return;
    // Su web: apri link nel browser
    if (kIsWeb) {
      // non possiamo installare su web, ma possiamo mostrare il link
      setState(() => _updateMessage = 'Scarica la nuova versione dal sito:\n$_downloadUrl');
      return;
    }
    // Solo Windows supporta install automatico
    if (defaultTargetPlatform != TargetPlatform.windows) {
      setState(() => _updateMessage = 'Aggiornamento automatico disponibile solo su Windows.\nScarica manualmente da:\n$_downloadUrl');
      return;
    }

    setState(() { _downloading = true; _downloadProgress = 0; });
    try {
      final tmpDir = await getTemporaryDirectory();
      final installer = File('${tmpDir.path}\\VoliDiCarta_v${_latestVersion}_Setup.exe');

      final req = http.Request('GET', Uri.parse(_downloadUrl!));
      final response = await req.send().timeout(const Duration(minutes: 5));
      final total = response.contentLength ?? 0;
      int received = 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0 && mounted) {
          setState(() => _downloadProgress = received / total);
        }
      }
      await installer.writeAsBytes(bytes);
      if (!mounted) return;
      setState(() { _downloading = false; _downloadProgress = 1; });

      // Mostra conferma prima di avviare l'installer
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Aggiornamento scaricato'),
          content: Text('L\'installer di v${_latestVersion ?? ''} è pronto.\n\nVerrà avviato il wizard di installazione. L\'app si chiuderà.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Installa ora')),
          ],
        ),
      );
      if (confirm != true) return;

      // Avvia l'installer e chiudi l'app
      await Process.start(installer.path, [], runInShell: false);
      exit(0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _updateMessage = 'Download fallito: ${e.toString()}\n\nScarica manualmente da:\n$_downloadUrl';
          _hasUpdate = true;
        });
      }
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
                  'Voli di Carta',
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
