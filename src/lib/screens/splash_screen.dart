import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../services/auth_service.dart';
import '../services/crash_service.dart';
import '../services/review_sync_service.dart';
import '../services/supabase_service.dart';
import '../services/update_service.dart';
import '../widgets/gdpr_consent_dialog.dart';
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
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1000)),
      _initServices(),
    ]);
    if (!mounted) return;

    // Consenso GDPR — mostrato solo al primo avvio
    final consentAccepted = await GdprConsentDialog.showIfNeeded(context);
    if (!mounted) return;

    // Sync recensioni + aggiorna presenza (solo se consenso dato)
    final uid = AuthService().currentUser?.id;
    if (SupabaseConfig.isInitialized) {
      if (uid != null) {
        ReviewSyncService().syncFromCloud(uid);
        if (consentAccepted) SupabaseService().updatePresence();
      } else if (consentAccepted) {
        // Utente non registrato: traccia come sessione anonima solo con consenso
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

    // Check e download aggiornamento automatico in background (Android e Windows)
    if (!kIsWeb && (isAndroid || isWindows)) {
      try {
        String currentVersion = '';
        try {
          final info = await PackageInfo.fromPlatform();
          currentVersion = info.version;
        } catch (_) {}
        if (currentVersion.isNotEmpty) {
          final update = await UpdateService().checkForUpdate(currentVersion);
          if (update != null && update.isNewerAvailable) {
            // Avvia download + install in background senza attendere né mostrare dialog
            UpdateService().downloadAndInstall(update).ignore();
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

  Future<void> _initServices() async {
    try {
      await AuthService().loadSession();
      await Future.delayed(const Duration(milliseconds: 300));
      await AuthService().refreshAdminStatus();
    } catch (e) {
      debugPrint('SplashScreen init error: $e');
    }
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
    if (crash == null) return;

    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (_) {}
    final platform = defaultTargetPlatform == TargetPlatform.android ? 'Android' : 'Windows';

    final issueBody = [
      '## Crash automatico rilevato',
      '',
      '## Informazioni',
      '- **Versione**: ${version.isNotEmpty ? version : 'n/d'}',
      '- **Piattaforma**: $platform',
      '- **Data crash**: ${crash.time}',
      '',
      '## Errore',
      '```',
      crash.error,
      '```',
      '<details><summary>Stack trace</summary>',
      '',
      '```',
      crash.stack.length > 3000 ? crash.stack.substring(0, 3000) : crash.stack,
      '```',
      '</details>',
    ].join('\n');

    // Invia automaticamente — nessuna interazione richiesta all'utente
    try {
      await http.post(
        Uri.parse('${SupabaseConfig.url}/functions/v1/github-issue'),
        headers: {
          'Authorization': 'Bearer ${SupabaseConfig.anonJwt}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': 'Crash automatico su $platform${version.isNotEmpty ? ' v$version' : ''}',
          'body': issueBody,
          'labels': ['bug', 'crash-auto'],
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Invio fallito silenziosamente — il crash resterà in memoria per il prossimo avvio
      return;
    }

    await CrashService.clear();

    // Toast discreto
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crash rilevato e segnalato automaticamente.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
