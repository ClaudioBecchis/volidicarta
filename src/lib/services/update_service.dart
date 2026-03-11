import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../config/supabase_config.dart';
import '../database/db_helper.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String? downloadUrl;
  final String? sha256;
  final String? releaseNotes;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    this.downloadUrl,
    this.sha256,
    this.releaseNotes,
  });

  bool get isNewerAvailable => _isNewer(latestVersion, currentVersion);

  static bool _isNewer(String latest, String current) {
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
}

class UpdateService {
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._();

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  Future<UpdateInfo?> checkForUpdate(String currentVersion) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      final uri = Uri.parse(
          '${SupabaseConfig.url}/rest/v1/app_version'
          '?select=version,release_notes,download_url,sha256_checksum'
          '&order=id.desc&limit=1');
      final res = await http.get(uri, headers: {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) return null;

      final row = data.first as Map<String, dynamic>;
      return UpdateInfo(
        latestVersion: row['version'] as String,
        currentVersion: currentVersion,
        downloadUrl: row['download_url'] as String?,
        sha256: row['sha256_checksum'] as String?,
        releaseNotes: row['release_notes'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  String? apkUrl(String? downloadUrl, String version) {
    if (downloadUrl == null) return null;
    final base = downloadUrl.substring(0, downloadUrl.lastIndexOf('/'));
    return '$base/Voli.di.Carta_v$version.apk';
  }

  /// Scarica e installa l'aggiornamento in background senza interazione utente.
  /// Su Android: lancia il wizard di installazione del sistema operativo.
  /// Su Windows: avvia l'installer EXE e chiude l'app.
  Future<void> downloadAndInstall(UpdateInfo info) async {
    try {
      final tmpDir = await getTemporaryDirectory();

      if (isAndroid) {
        final url = apkUrl(info.downloadUrl, info.latestVersion)
            ?? info.downloadUrl!;
        final apkFile = File('${tmpDir.path}/VDC_update_${info.latestVersion}.apk');

        if (!apkFile.existsSync()) {
          final req = http.Request('GET', Uri.parse(url));
          final response = await req.send().timeout(const Duration(minutes: 10));
          await apkFile.writeAsBytes(await response.stream.toBytes());
        }

        // Lancia il wizard di installazione nativo — unica azione richiesta all'utente
        await OpenFilex.open(
          apkFile.path,
          type: 'application/vnd.android.package-archive',
        );
        return;
      }

      if (isWindows) {
        final exeFile = File(
            '${tmpDir.path}\\VDC_update_${info.latestVersion}.exe');

        if (!exeFile.existsSync()) {
          final req = http.Request('GET', Uri.parse(info.downloadUrl!));
          final response = await req.send().timeout(const Duration(minutes: 10));
          await exeFile.writeAsBytes(await response.stream.toBytes());
        }

        // Verifica integrità SHA-256
        if (info.sha256 != null && info.sha256!.isNotEmpty) {
          final digest = sha256.convert(await exeFile.readAsBytes());
          if (digest.toString() != info.sha256) {
            await exeFile.delete();
            throw Exception('SHA-256 mismatch: installer corrotto o manomesso');
          }
        }

        // /S = silent install (NSIS standard flag)
        await Process.start(exeFile.path, ['/S']);
        await Future.delayed(const Duration(milliseconds: 500));
        await DbHelper().close();
        await SystemNavigator.pop();
      }
    } catch (_) {
      // Fallimento silenzioso — l'aggiornamento verrà ritentato al prossimo avvio
    }
  }
}
