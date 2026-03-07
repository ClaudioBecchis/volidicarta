# BookShelf 📚

**BookShelf** è un'app Flutter open source per tenere traccia dei libri che leggi, scrivere recensioni e condividerle con la community.

Sviluppata da **Claudio Becchis** · [polariscore.it](https://polariscore.it)

---

## Funzionalità

- 🔍 Ricerca libri tramite Google Books API (tutti gli editori)
- ⭐ Recensioni con valutazione a stelle e note personali
- 📅 Data inizio e fine lettura
- 📊 Statistiche personali di lettura
- 🌍 Community pubblica: condividi le tue recensioni
- 🎨 Tema chiaro / scuro / sistema
- 🌐 10 lingue supportate
- 🔄 Controlla aggiornamenti integrato

## Piattaforme

| Piattaforma | Stato |
|-------------|-------|
| Windows     | ✅ |
| Android     | ✅ |
| iOS / macOS | 🔜 (richiede Mac) |
| Web         | 🔜 (in sviluppo) |

---

## Installazione (utenti finali)

Scarica l'ultima versione dalla sezione [Releases](../../releases):

- **Windows**: `BookShelf_Setup_v*.exe`
- **Android**: `app-release.apk`

---

## Setup per sviluppatori

### Prerequisiti

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41
- [Supabase](https://supabase.com) account gratuito

### 1. Clona il repo

```bash
git clone https://github.com/claudiobecchis/bookshelf.git
cd bookshelf/src
```

### 2. Configura Supabase

```bash
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
```

Apri `lib/config/supabase_config.dart` e inserisci le tue credenziali Supabase (Project URL e anon key).

Poi vai su **SQL Editor** in Supabase e incolla il contenuto di `supabase_schema.sql`.

### 3. Installa dipendenze e compila

```bash
flutter pub get
flutter run -d windows   # Windows
flutter run -d android   # Android (emulatore o device)
```

---

## Struttura del progetto

```
src/
  lib/
    config/         # Configurazione Supabase
    database/       # SQLite locale (recensioni)
    models/         # Book, Review, PublicReview, User
    screens/        # Tutte le schermate
    services/       # API, Auth, Supabase, Settings
    widgets/        # Widget riutilizzabili
  android/          # Progetto Android
  windows/          # Progetto Windows
supabase_schema.sql # Schema database Supabase
bookshelf_setup.iss # Script InnoSetup (installer Windows)
```

---

## Licenza

MIT License — vedi [LICENSE](LICENSE)

© 2025 Claudio Becchis · polariscore.it
