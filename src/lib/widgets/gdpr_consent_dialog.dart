import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GdprConsentDialog extends StatelessWidget {
  const GdprConsentDialog({super.key});

  static const _key = 'gdpr_consent_given';

  /// Restituisce true se l'utente ha già dato (o rifiutato) il consenso.
  static Future<bool> alreadyAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  /// Restituisce true se l'utente ha accettato il tracciamento anonimo.
  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> _save(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, accepted);
  }

  /// Mostra il dialog se l'utente non ha ancora risposto.
  /// Restituisce true se ha accettato il tracciamento.
  static Future<bool> showIfNeeded(BuildContext context) async {
    if (await alreadyAnswered()) {
      return isAccepted();
    }
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GdprConsentDialog(),
    );
    final accepted = result ?? false;
    await _save(accepted);
    return accepted;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: Color(0xFF1A5276)),
          SizedBox(width: 10),
          Text('Privacy & dati', style: TextStyle(fontSize: 17)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voli di Carta è un\'app gratuita e open source.\n\n'
              'Per migliorare l\'app raccogliamo in modo anonimo:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            _bullet(Icons.tag, 'Un ID sessione casuale (non ti identifica personalmente)'),
            _bullet(Icons.devices, 'Il tipo di dispositivo (Android / Windows / Web)'),
            _bullet(Icons.people_outline, 'Il conteggio degli utenti attivi (statistiche aggregate)'),
            const SizedBox(height: 12),
            const Text(
              'Se ti registri alla community, salviamo anche email e username su Supabase (server UE).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ricerca libri: le query vengono inviate a Google Books e Open Library (soggette alle loro policy).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('https://claudiobecchis.github.io/volidicarta/privacy-policy.html'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text(
                '📄 Leggi la Privacy Policy completa',
                style: TextStyle(
                  color: Color(0xFF1A5276),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Accetta'),
        ),
      ],
    );
  }

  Widget _bullet(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF1A5276)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
}
