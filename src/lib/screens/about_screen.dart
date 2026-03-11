import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_colors.dart';
import '../l10n/app_strings.dart';
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
      _currentVersion = '1.3.12';
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


  String get _platform => kIsWeb
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

  Future<String?> _postGitHubIssue({
    required String title,
    required String body,
    required List<String> labels,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('${SupabaseConfig.url}/functions/v1/github-issue'),
        headers: {
          'Authorization': 'Bearer ${SupabaseConfig.anonJwt}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': title, 'body': body, 'labels': labels}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['html_url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _suggestImprovement() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFFF39C12)),
          const SizedBox(width: 10),
          Text(S.of(ctx).suggestImprovement, style: const TextStyle(fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hai un\'idea per migliorare l\'app? Descrivila qui sotto e verrà inviata direttamente agli sviluppatori.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titolo breve',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  hintText: 'Descrivi la funzionalità o il miglioramento...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39C12),
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(ctx).send),
          ),
        ],
      ),
    );
    titleCtrl.dispose();
    bodyCtrl.dispose();
    if (result != true || !mounted) return;
    final t = titleCtrl.text.trim();
    final b = bodyCtrl.text.trim();
    if (t.isEmpty) return;
    final issueBody = [
      '## Descrizione del suggerimento',
      '',
      b.isNotEmpty ? b : '_Nessuna descrizione fornita._',
      '',
      '## Informazioni',
      '- **Versione**: $_currentVersion',
      '- **Piattaforma**: $_platform',
    ].join('\n');
    final url = await _postGitHubIssue(
      title: 'Suggerimento: $t',
      body: issueBody,
      labels: ['enhancement'],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(url != null
          ? 'Suggerimento inviato! Grazie per il feedback.'
          : 'Errore di invio. Riprova più tardi.'),
      backgroundColor: url != null ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _reportBug() async {
    final crash = await CrashService.load();
    if (!mounted) return;
    final descCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.bug_report_outlined, color: Colors.red),
          const SizedBox(width: 10),
          Text(S.of(ctx).reportBug, style: const TextStyle(fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Descrivi cosa stavi facendo quando si è verificato il problema.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrizione del problema',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Versione: $_currentVersion · Piattaforma: $_platform'
                  '${crash != null ? '\nUltimo crash: ${crash.time}' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(ctx).send),
          ),
        ],
      ),
    );
    descCtrl.dispose();
    if (result != true || !mounted) return;
    final desc = descCtrl.text.trim();
    final issueBody = [
      '## Descrizione del problema',
      '',
      desc.isNotEmpty ? desc : '_Nessuna descrizione fornita._',
      '',
      '## Informazioni',
      '- **Versione**: $_currentVersion',
      '- **Piattaforma**: $_platform',
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
    ].join('\n');
    final url = await _postGitHubIssue(
      title: 'Bug su $_platform v$_currentVersion',
      body: issueBody,
      labels: ['bug'],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(url != null
          ? 'Bug segnalato! Grazie per la segnalazione.'
          : 'Errore di invio. Riprova più tardi.'),
      backgroundColor: url != null ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }


  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.screenBg(context),
      appBar: AppBar(title: Text(s.appInfo)),
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
                // Donazione Ko-fi
                _DonateCard(),
                const SizedBox(height: 8),
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
                  label: Text(s.reportBug),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
                const SizedBox(height: 8),
                // Suggerisci miglioramento
                OutlinedButton.icon(
                  onPressed: _suggestImprovement,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(s.suggestImprovement),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade800,
                    side: BorderSide(color: Colors.amber.shade400),
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

class _DonateCard extends StatelessWidget {
  static const _paypalUrl = 'https://paypal.me/CBECCHIS?locale.x=it_IT&country.x=IT';
  static const _kofiUrl = 'https://ko-fi.com/polariscore';
  static const _satispayUrl = 'https://www.satispay.com/app/satispay/send-money/user/claudiobecchis';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5E5B), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5E5B).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('☕', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Supporta lo sviluppo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Se ti piace l\'app, una donazione aiuta a mantenerla aggiornata e migliorarla nel tempo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(_paypalUrl),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.payment, size: 15),
                label: const Text('PayPal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF003087),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(_satispayUrl),
                    mode: LaunchMode.externalApplication),
                icon: const Text('💸', style: TextStyle(fontSize: 13)),
                label: const Text('Satispay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE3000F),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(_kofiUrl),
                    mode: LaunchMode.externalApplication),
                icon: const Text('☕', style: TextStyle(fontSize: 13)),
                label: const Text('Ko-fi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF5E5B),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
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
