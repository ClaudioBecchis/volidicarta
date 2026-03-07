import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF5FB),
      appBar: AppBar(title: const Text('Info App')),
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
                        color: const Color(0xFF1A5276).withOpacity(0.3),
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
                  'BookShelf',
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
                    color: const Color(0xFF1A5276).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Versione 1.0.0',
                    style: TextStyle(
                        color: Color(0xFF1A5276),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 40),
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
                _FeatureRow(
                    icon: Icons.search,
                    text: 'Ricerca su Google Books (Amazon, Feltrinelli, IBS...)'),
                _FeatureRow(
                    icon: Icons.star_rounded,
                    text: 'Recensioni con valutazione a stelle'),
                _FeatureRow(
                    icon: Icons.category_outlined,
                    text: 'Organizzazione per Autore e Genere'),
                _FeatureRow(
                    icon: Icons.bar_chart,
                    text: 'Statistiche di lettura personali'),
                _FeatureRow(
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
