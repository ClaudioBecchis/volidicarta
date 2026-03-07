import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final currentLang = _settings.locale.languageCode;
    final currentTheme = _settings.themeMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Tema ──────────────────────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.palette_outlined,
                        color: Color(0xFF1A5276)),
                    const SizedBox(width: 8),
                    Text(s.theme,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    icon: Icons.light_mode_outlined,
                    label: s.themeLight,
                    selected: currentTheme == ThemeMode.light,
                    onTap: () => _setTheme(ThemeMode.light),
                  ),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    label: s.themeDark,
                    selected: currentTheme == ThemeMode.dark,
                    onTap: () => _setTheme(ThemeMode.dark),
                  ),
                  _ThemeOption(
                    icon: Icons.brightness_auto_outlined,
                    label: s.themeSystem,
                    selected: currentTheme == ThemeMode.system,
                    onTap: () => _setTheme(ThemeMode.system),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Lingua ────────────────────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.language_outlined,
                        color: Color(0xFF1A5276)),
                    const SizedBox(width: 8),
                    Text(s.language,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 12),
                  ...SettingsService.supportedLanguages.map((lang) {
                    final selected = lang['code'] == currentLang;
                    return InkWell(
                      onTap: () => _setLocale(lang['code']!),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1A5276).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: selected
                              ? Border.all(
                                  color: const Color(0xFF1A5276)
                                      .withOpacity(0.4))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(lang['name']!,
                                style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selected
                                        ? const Color(0xFF1A5276)
                                        : null)),
                            const Spacer(),
                            if (selected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF1A5276), size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'BookShelf v1.0.0\nClaudio Becchis · polariscore.it',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _setTheme(ThemeMode mode) {
    _settings.setTheme(mode);
    setState(() {});
  }

  void _setLocale(String code) {
    _settings.setLocale(Locale(code));
    setState(() {});
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A5276).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(
                  color: const Color(0xFF1A5276).withOpacity(0.4))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFF1A5276) : Colors.grey,
                size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color:
                        selected ? const Color(0xFF1A5276) : null)),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF1A5276), size: 18),
          ],
        ),
      ),
    );
  }
}
