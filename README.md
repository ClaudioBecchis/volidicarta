<p align="center">
  <img src="banner.png" alt="Voli di Carta - Open Source Flutter Book Tracker" width="100%">
</p>

# Voli di Carta

**Voli di Carta** è un'app Flutter open source per tenere traccia dei libri che leggi, scrivere recensioni e condividerle con la community.

Sviluppata da **Claudio Becchis** · [polariscore.it](https://polariscore.it)

[![Release](https://img.shields.io/github/v/release/ClaudioBecchis/volidicarta?label=versione)](../../releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.41-blue?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/piattaforme-Windows%20%7C%20Android-green)](../../releases/latest)

---

## Funzionalità

- Ricerca libri tramite Google Books API (tutti gli editori)
- Recensioni con valutazione a stelle e note personali
- Data inizio e fine lettura
- Lista "Da Leggere" (wishlist)
- Statistiche personali di lettura
- Community pubblica: condividi le tue recensioni
- Aggiornamenti automatici in-app
- Tema chiaro / scuro / sistema
- 10 lingue supportate

## Piattaforme

| Piattaforma | Stato |
|-------------|-------|
| Windows     | ✅ |
| Android     | ✅ |
| Web         | ✅ [Prova online](https://claudiobecchis.github.io/volidicarta/) |
| iOS / macOS | 🔜 (richiede Mac) |

---

## Download

Scarica l'ultima versione dalla sezione [Releases](../../releases/latest):

- **Windows**: `Voli-di-Carta-vX.X.X-Setup.exe`
- **Android**: `Voli-di-Carta-vX.X.X.apk`

---

## Setup per sviluppatori

### Prerequisiti

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41
- [Supabase](https://supabase.com) account gratuito (opzionale per community)

### 1. Clona il repo

```bash
git clone https://github.com/ClaudioBecchis/volidicarta.git
cd volidicarta/src
```

### 2. Configura Supabase (opzionale)

```bash
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
```

Apri `lib/config/supabase_config.dart` e inserisci le tue credenziali Supabase.

### 3. Installa dipendenze e avvia

```bash
flutter pub get
flutter run -d windows   # Windows
flutter run -d android   # Android
flutter run -d chrome    # Web
```

---

## Struttura del progetto

```
src/
  lib/
    config/         # Configurazione (Supabase, API key)
    database/       # SQLite locale (recensioni, wishlist)
    models/         # Book, Review, WishlistBook, PublicReview
    screens/        # Tutte le schermate
    services/       # API Google Books, Auth, Supabase, Settings
    widgets/        # Widget riutilizzabili
  android/          # Progetto Android
  windows/          # Progetto Windows
  web/              # Progetto Web
supabase_schema.sql # Schema database Supabase
bookshelf_setup.iss # Script InnoSetup (installer Windows)
```

---

## Licenza

MIT License — vedi [LICENSE](LICENSE)

© 2026 Claudio Becchis · polariscore.it
