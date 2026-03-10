import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../services/update_service.dart';
import '../database/db_helper.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const UpdateDialog({super.key, required this.info});

  /// Mostra il dialog solo se c'è un aggiornamento disponibile.
  static Future<void> showIfNeeded(BuildContext context, UpdateInfo info) async {
    if (!info.isNewerAvailable) return;
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(info: info),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  Future<void> _update() async {
    final info = widget.info;

    // Web o piattaforme non supportate: apri link nel browser
    if (!UpdateService.isAndroid && !UpdateService.isWindows) {
      final uri = Uri.parse(info.downloadUrl ?? '');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() { _downloading = true; _progress = 0; _error = null; });

    try {
      final tmpDir = await getTemporaryDirectory();
      final fileName = UpdateService.isAndroid
          ? 'VoliDiCarta_v${info.latestVersion}.apk'
          : 'VoliDiCarta_v${info.latestVersion}_Setup.exe';
      final sep = UpdateService.isAndroid ? '/' : '\\';
      final installer = File('${tmpDir.path}$sep$fileName');

      final downloadUrl = UpdateService.isAndroid
          ? (UpdateService().apkUrl(info.downloadUrl, info.latestVersion) ?? info.downloadUrl!)
          : info.downloadUrl!;

      final req = http.Request('GET', Uri.parse(downloadUrl));
      final response = await req.send().timeout(const Duration(minutes: 10));
      final total = response.contentLength ?? 0;
      int received = 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0 && mounted) {
          setState(() => _progress = received / total);
        }
      }
      await installer.writeAsBytes(bytes);

      // Verifica SHA-256 (solo su Windows — l'APK ha un hash diverso da quello EXE)
      if (!UpdateService.isAndroid && info.sha256 != null && info.sha256!.isNotEmpty) {
        final digest = sha256.convert(await installer.readAsBytes());
        if (digest.toString() != info.sha256) {
          await installer.delete();
          if (mounted) setState(() { _downloading = false; _error = 'Verifica integrità fallita. Riprova.'; });
          return;
        }
      }

      if (!mounted) return;
      setState(() { _downloading = false; _progress = 1; });

      // ── Android: lancia il wizard di installazione nativo ────────────────
      if (UpdateService.isAndroid) {
        await OpenFilex.open(installer.path, type: 'application/vnd.android.package-archive');
        if (mounted) Navigator.pop(context);
        return;
      }

      // ── Windows: chiedi conferma e avvia setup ───────────────────────────
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Pronto per installare'),
          content: Text(
              'v${info.latestVersion} scaricata.\nL\'app si chiuderà per avviare il wizard di installazione.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5276),
                    foregroundColor: Colors.white),
                child: const Text('Installa ora')),
          ],
        ),
      );
      if (confirm != true) return;

      await Process.start(installer.path, []);
      await Future.delayed(const Duration(milliseconds: 500));
      await DbHelper().close();
      await SystemNavigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = 'Download fallito. Controlla la connessione.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final isAndroid = UpdateService.isAndroid;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A5276).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.system_update_alt_rounded,
                color: Color(0xFF1A5276), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Aggiornamento disponibile',
                style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('v${info.currentVersion}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text('v${info.latestVersion}',
                  style: const TextStyle(
                      color: Color(0xFF1A5276),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                info.releaseNotes!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (_downloading) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF1A5276),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _progress > 0
                  ? 'Download: ${(_progress * 100).toStringAsFixed(0)}%'
                  : 'Download in corso...',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          if (isAndroid && !_downloading) ...[
            const SizedBox(height: 10),
            Text(
              'L\'APK verrà scaricato automaticamente.\nAl termine apparirà il wizard di installazione.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
      actions: _downloading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Più tardi'),
              ),
              ElevatedButton.icon(
                onPressed: _update,
                icon: const Icon(Icons.system_update_alt_rounded, size: 18),
                label: Text(isAndroid ? 'Installa aggiornamento' : 'Aggiorna ora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5276),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
    );
  }
}
