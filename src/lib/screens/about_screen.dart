import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/supabase_config.dart';
import '../services/crash_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  /// Esposto per i test — confronto semver "latest > current"
  static bool isNewerVersion(String latest, String current) =>
      _AboutScreenState._isNewerVersion(latest, current);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _currentVersion = '';
  bool _checking = false;
  String? _updateMessage;
  bool _hasUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _currentVersion = info.version);
    } catch (_) {
      // Fallback: leggi dal pubspec tramite rootBundle è non disponibile qui;
      // usa stringa statica solo se PackageInfo non è disponibile
      _currentVersion = '1.3.0';
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    try {
      final l = latest.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final li = i < l.length ? l[i] : 0;
        final ci = i < c.length ? c[i] : 0;
        if (li > ci) return true;
        if (li < ci) return false;
      }
      return false;
    } catch (_) {
      return latest != current;
    }
  }

  Future<void> _checkUpdates() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _updateMessage = 'Aggiornamenti non disponibili in questa build.');
      return;
    }
    setState(() { _checking = true; _updateMessage = null; _hasUpdate = false; });
    try {
      final update = await UpdateService().checkForUpdate(_currentVersion);
      if (!mounted) return;
      if (update == null) {
        setState(() => _updateMessage = 'Impossibile verificare gli aggiornamenti.');
      } else if (update.isNewerAvailable) {
        setState(() {
          _hasUpdate = true;
          _updateMessage = 'Nuova versione disponibile: v${update.latestVersion}';
        });
        await UpdateDialog.showIfNeeded(context, update);
      } else {
        setState(() => _updateMessage = 'Sei già alla versione più recente (v${update.latestVersion}).');
      }
    } catch (_) {
      setState(() => _updateMessage = 'Errore di rete. Controlla la connessione.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _reportBug() async {
    final crash = await CrashService.load();
    final platform = kIsWeb
        ? 'Web'
        : defaultTargetPlatform == TargetPlatform.android
            ? 'Android'
            : defaultTargetPlatform == TargetPlatform.windows
                ? 'Windows'
                : defaultTargetPlatform == TargetPlatform.iOS
                    ? 'iOS'
                    : defaultTargetPlatform == TargetPlatform.macOS
                        ? 'macOS'
                        : defaultTargetPlatform == TargetPlatform.linux
                            ? 'Linux'
                            : 'Unknown';
    final title = Uri.encodeComponent('Bug su $platform v$_currentVersion');
    final body = Uri.encodeComponent([
      '## Descrizione del problema',
      '',
      '_Descrivi qui cosa stavi facendo quando si è verificato il problema._',
      '',
      '## Informazioni',
      '- **Versione**: $_currentVersion',
      '- **Piattaforma**: $platform',
      if (crash != null) ...[
        '',
        '## Ultimo crash registrato (${crash.time})',
        '```',
        crash.error,
        '```',
        '<details><summary>Stack trace</summary>',
        '',
        '```',
        crash.stack.length > 2000 ? crash.stack.substring(0, 2000) : crash.stack,
        '```',
        '</details>',
      ] else ...[
        '- **Crash registrato**: nessuno',
      ],
    ].join('\n'));
    final uri = Uri.parse(
        'https://github.com/ClaudioBecchis/volidicarta/issues/new?title=$title&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il browser')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
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
                        color: const Color(0xFF1A5276).withValues(alpha: 0.3),
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
                    color: const Color(0xFF1A5276).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Versione $_currentVersion',
                    style: const TextStyle(
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
                const SizedBox(height: 12),
                // Segnala Bug
                OutlinedButton.icon(
                  onPressed: _reportBug,
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('Segnala un Bug'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
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
                const _FeatureRow(
                    icon: Icons.search,
                    text: 'Ricerca su Google Books (Amazon, Feltrinelli, IBS...)'),
                const _FeatureRow(
                    icon: Icons.star_rounded,
                    text: 'Recensioni con valutazione a stelle'),
                const _FeatureRow(
                    icon: Icons.category_outlined,
                    text: 'Organizzazione per Autore e Genere'),
                const _FeatureRow(
                    icon: Icons.bar_chart,
                    text: 'Statistiche di lettura personali'),
                const _FeatureRow(
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
