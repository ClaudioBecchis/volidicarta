import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/supabase_config.dart';

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

  /// Restituisce l'URL APK Android sostituendo il link EXE con l'APK
  String? apkUrl(String? downloadUrl, String version) {
    if (downloadUrl == null) return null;
    // Il download_url punta all'EXE, costruiamo l'URL APK nella stessa release
    final base = downloadUrl.substring(0, downloadUrl.lastIndexOf('/'));
    return '$base/Voli.di.Carta_v$version.apk';
  }
}
