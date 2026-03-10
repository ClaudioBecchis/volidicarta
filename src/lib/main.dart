import 'dart:async';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/crash_service.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CrashService.install();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS: sqflite nativo, nessuna inizializzazione necessaria
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        authOptions: const FlutterAuthClientOptions(
          detectSessionInUri: false,
        ),
      );
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }
  try {
    await SettingsService().load();
  } catch (e) {
    debugPrint('SettingsService load error: $e');
  }
  runZonedGuarded(
    () => runApp(const BookReviewApp()),
    (error, stack) => CrashService.save(error, stack),
  );
}

class BookReviewApp extends StatefulWidget {
  const BookReviewApp({super.key});

  @override
  State<BookReviewApp> createState() => _BookReviewAppState();
}

class _BookReviewAppState extends State<BookReviewApp> {
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voli di Carta',
      debugShowCheckedModeBanner: false,
      themeMode: _settings.themeMode,
      locale: _settings.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SettingsService.supportedLanguages
          .map((l) => Locale(l['code']!))
          .toList(),
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('it');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('it');
      },
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A5276),
        brightness: brightness,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF0D2B3E) : const Color(0xFF1A5276),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF2471A3) : const Color(0xFF1A5276),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A5276), width: 2),
        ),
      ),
    );
  }
}
