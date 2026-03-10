import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../l10n/app_strings.dart';
import '../widgets/gdpr_consent_dialog.dart';

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
                              ? const Color(0xFF1A5276).withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: selected
                              ? Border.all(
                                  color: const Color(0xFF1A5276)
                                      .withValues(alpha: 0.4))
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

          const SizedBox(height: 12),

          // ── Privacy ───────────────────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF1A5276)),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Leggi come utilizziamo i dati',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                  onTap: () => launchUrl(
                    Uri.parse('https://claudiobecchis.github.io/volidicarta/privacy-policy.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.manage_history_outlined, color: Color(0xFF1A5276)),
                  title: const Text('Gestisci consenso dati'),
                  subtitle: const Text('Modifica le preferenze di tracciamento',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showConsentManager(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // ── Donazione ─────────────────────────────────────────────────────
          Container(
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
                  color: const Color(0xFFFF5E5B).withValues(alpha: 0.25),
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
                    Text('☕', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Supporta lo sviluppo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Una donazione aiuta a mantenere l\'app aggiornata.',
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
                      onPressed: () => launchUrl(
                        Uri.parse('https://paypal.me/CBECCHIS?locale.x=it_IT&country.x=IT'),
                        mode: LaunchMode.externalApplication,
                      ),
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
                      onPressed: () => launchUrl(
                        Uri.parse('https://www.satispay.com/app/satispay/send-money/user/claudiobecchis'),
                        mode: LaunchMode.externalApplication,
                      ),
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
                      onPressed: () => launchUrl(
                        Uri.parse('https://ko-fi.com/polariscore'),
                        mode: LaunchMode.externalApplication,
                      ),
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
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Voli di Carta v1.0.7\nClaudio Becchis · polariscore.it',
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

  Future<void> _showConsentManager(BuildContext context) async {
    final current = await GdprConsentDialog.isAccepted();
    if (!context.mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.manage_history_outlined, color: Color(0xFF1A5276)),
          SizedBox(width: 10),
          Text('Tracciamento anonimo', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current
                  ? 'Hai accettato il tracciamento anonimo per le statistiche aggregate.'
                  : 'Hai rifiutato il tracciamento anonimo.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Puoi cambiare questa preferenza in qualsiasi momento.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Rifiuta', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5276),
              foregroundColor: Colors.white,
            ),
            child: const Text('Accetta'),
          ),
        ],
      ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gdpr_consent_given', result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result
              ? 'Consenso accettato'
              : 'Consenso rifiutato — nessun dato anonimo inviato'),
          duration: const Duration(seconds: 2),
        ));
      }
    }
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
              ? const Color(0xFF1A5276).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(
                  color: const Color(0xFF1A5276).withValues(alpha: 0.4))
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
