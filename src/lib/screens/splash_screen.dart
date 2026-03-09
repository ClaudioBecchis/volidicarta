import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/supabase_config.dart';
import '../services/auth_service.dart';
import '../services/crash_service.dart';
import '../services/review_sync_service.dart';
import '../services/supabase_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      await AuthService().loadSession();
    } catch (e) {
      debugPrint('SplashScreen init error: $e');
    }
    if (!mounted) return;

    // Sync recensioni + aggiorna presenza
    final uid = AuthService().currentUser?.id;
    if (SupabaseConfig.isInitialized) {
      if (uid != null) {
        ReviewSyncService().syncFromCloud(uid);
        SupabaseService().updatePresence();
      } else {
        // Utente non registrato: traccia come sessione anonima
        _trackAnonymousPresence();
      }
    }

    // Mostra dialog crash report su Android e Windows (non su Web)
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    if (isAndroid || isWindows) {
      try {
        await _checkAndReportCrash();
      } catch (e) {
        debugPrint('Crash report dialog error: $e');
      }
    }

    // Check aggiornamento automatico (Android e Windows)
    if (!kIsWeb && (isAndroid || isWindows) && mounted) {
      try {
        String currentVersion = '';
        try {
          final info = await PackageInfo.fromPlatform();
          currentVersion = info.version;
        } catch (_) {}
        if (currentVersion.isNotEmpty) {
          final update = await UpdateService().checkForUpdate(currentVersion);
          if (update != null && update.isNewerAvailable && mounted) {
            await UpdateDialog.showIfNeeded(context, update);
          }
        }
      } catch (e) {
        debugPrint('Update check error: $e');
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _trackAnonymousPresence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('anon_session_id');
      if (sessionId == null) {
        final r = Random.secure();
        sessionId = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
        await prefs.setString('anon_session_id', sessionId);
      }
      String platform = 'unknown';
      if (kIsWeb) {
        platform = 'web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        platform = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        platform = 'windows';
      }
      await SupabaseService().updateAnonPresence(sessionId, platform);
    } catch (_) {}
  }

  Future<void> _checkAndReportCrash() async {
    final crash = await CrashService.load();
    if (crash == null || !mounted) return;

    final report = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Crash rilevato'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("L'app è crashata durante l'ultima sessione."),
            const SizedBox(height: 8),
            Text(
              crash.error.length > 120
                  ? '${crash.error.substring(0, 120)}…'
                  : crash.error,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vuoi segnalare il problema su GitHub?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, grazie'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Segnala'),
          ),
        ],
      ),
    );

    await CrashService.clear();

    if (report == true) {
      String version = '';
      try {
        final info = await PackageInfo.fromPlatform();
        version = info.version;
      } catch (_) {}
      final platform = _isAndroidPlatform(defaultTargetPlatform) ? 'Android' : 'Windows';
      final title = Uri.encodeComponent('Bug su $platform${version.isNotEmpty ? ' v$version' : ''}');
      final body = Uri.encodeComponent([
        '## Descrizione del problema',
        '',
        '_Descrivi qui cosa stavi facendo quando si è verificato il problema._',
        '',
        '## Informazioni',
        '- **Versione**: ${version.isNotEmpty ? version : 'n/d'}',
        '- **Piattaforma**: $platform',
        '',
        '## Crash registrato (${crash.time})',
        '```',
        crash.error,
        '```',
        '<details><summary>Stack trace</summary>',
        '',
        '```',
        crash.stack.length > 2000 ? crash.stack.substring(0, 2000) : crash.stack,
        '```',
        '</details>',
      ].join('\n'));
      final uri = Uri.parse(
          'https://github.com/ClaudioBecchis/volidicarta/issues/new?title=$title&body=$body');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  static bool _isAndroidPlatform(TargetPlatform p) => p == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A5276),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 96, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Voli di Carta',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Le tue recensioni, sempre con te',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 40),
            const Text(
              'Claudio Becchis · polariscore.it',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
