import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    (
      icon: Icons.bar_chart_rounded,
      title: 'Statistiche avanzate',
      desc: 'Trend di lettura, confronto annuale, grafici dettagliati',
    ),
    (
      icon: Icons.picture_as_pdf_rounded,
      title: 'Export PDF / CSV',
      desc: 'Esporta la tua libreria e le tue recensioni',
    ),
    (
      icon: Icons.palette_rounded,
      title: 'Temi esclusivi',
      desc: 'Personalizza l\'app con temi premium e colori custom',
    ),
    (
      icon: Icons.workspace_premium_rounded,
      title: 'Badge Premium',
      desc: 'Profilo community con badge dorato e priorità nei post',
    ),
    (
      icon: Icons.cloud_sync_rounded,
      title: 'Backup cloud manuale',
      desc: 'Esporta e importa il tuo database in qualsiasi momento',
    ),
    (
      icon: Icons.auto_awesome_rounded,
      title: 'Suggerimenti AI',
      desc: 'Raccomandazioni personalizzate in base ai tuoi gusti',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 700;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: isDesktop ? 220 : 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                      Color(0xFF0F3460),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: isDesktop
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500)
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700)
                                            .withValues(alpha: 0.5),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Voli di Carta',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500)
                                        ],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 5),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFFFD700)
                                                .withValues(alpha: 0.5)),
                                        color: const Color(0xFFFFD700)
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: const Text(
                                        '€1,99 / mese · €14,99 / anno',
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700)
                                            .withValues(alpha: 0.5),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Voli di Carta',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500)
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFFFD700)
                                            .withValues(alpha: 0.5)),
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: const Text(
                                    '€1,99 / mese · €14,99 / anno',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenuto principale ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner "Prossimamente"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'In arrivo — iscriviti per essere il primo a sapere!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Titolo sezione
                      Text(
                        'Cosa include Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Griglia funzioni: 2 colonne su desktop, 1 su mobile
                      isDesktop
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 3.2,
                              ),
                              itemCount: _features.length,
                              itemBuilder: (context, i) =>
                                  _FeatureCard(feature: _features[i]),
                            )
                          : Column(
                              children: _features
                                  .map((f) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _FeatureCard(feature: f),
                                      ))
                                  .toList(),
                            ),
                      const SizedBox(height: 24),
                      // Bottone CTA
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showComingSoon(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_active_rounded,
                                      color: Colors.white, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Avvisami al lancio',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Note legali
                      Text(
                        'I prezzi sono indicativi e potranno variare al lancio.\nPotrai disdire in qualsiasi momento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('🚀', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Text('Prossimamente!',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        content: const Text(
          'Il piano Premium è in sviluppo.\n\nSeguici su GitHub per ricevere aggiornamenti sul lancio.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ({IconData icon, String title, String desc}) feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              color: Color(0xFFFFD700), size: 18),
        ],
      ),
    );
  }
}
