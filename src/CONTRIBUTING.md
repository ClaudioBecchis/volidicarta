# Contribuire a Voli di Carta

Grazie per l'interesse nel contribuire! Ecco le linee guida per partecipare allo sviluppo.

## Prerequisiti

- **Flutter** ≥ 3.3.0 (canale stable)
- **Dart** ≥ 3.3.0
- **Android Studio** o **VS Code** con estensioni Flutter/Dart
- **Git**

### Per build Windows
- Visual Studio 2022 con workload "Desktop development with C++"

### Per build Android
- Android SDK con API level 21+
- Java 17

## Struttura del progetto

```
lib/
├── config/          # Configurazione app (colori, Supabase, API keys)
├── database/        # SQLite helper (DbHelper singleton)
├── l10n/            # Localizzazione (10 lingue, inline maps)
├── models/          # Modelli dati (Book, Review, WishlistBook, etc.)
├── screens/         # Schermate UI (StatefulWidget con setState)
├── services/        # Logica business (API, auth, sync, crash, etc.)
├── utils/           # Utilità (date format, platform init, retry)
├── widgets/         # Widget riutilizzabili (star rating, book card, etc.)
└── main.dart        # Entry point
```

## Setup locale

1. **Clona il repository**
   ```bash
   git clone https://github.com/ClaudioBecchis/volidicarta.git
   cd volidicarta
   ```

2. **Installa dipendenze**
   ```bash
   flutter pub get
   ```

3. **Esegui l'app** (senza community)
   ```bash
   flutter run           # dispositivo predefinito
   flutter run -d chrome # web
   flutter run -d windows # desktop Windows
   ```

4. **Per attivare la community (opzionale)**
   - Crea un progetto gratuito su [supabase.com](https://supabase.com)
   - Esegui `supabase_schema.sql` nel SQL Editor
   - Copia URL e anon key in `lib/config/supabase_config.dart`
   - Ricompila l'app

## Convenzioni

### Commit

Usiamo [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: aggiunge filtro per genere nella lista recensioni
fix: corregge crash su tema scuro nella schermata dettaglio
docs: aggiorna README con istruzioni build
refactor: estrae logica retry in helper dedicato
test: aggiunge unit test per modello Review
chore: aggiorna dipendenze Flutter
```

### Codice

- **Stile**: `dart format` + regole in `analysis_options.yaml`
- **Lingua**: Codice e commenti in inglese, stringhe UI in italiano (con localizzazione)
- **State management**: `setState()` — no Provider/Bloc/Riverpod (per semplicità)
- **Servizi**: Pattern Singleton per servizi globali
- **Test**: Ogni PR dovrebbe includere test per la nuova funzionalità

### Branching

- `main` — branch stabile, sempre deployabile
- `feature/nome-feature` — nuove funzionalità
- `fix/descrizione-bug` — correzioni bug

## Test

```bash
# Esegui tutti i test
flutter test

# Esegui test specifico
flutter test test/models/review_test.dart

# Test con coverage
flutter test --coverage

# Analisi statica
flutter analyze
```

## Build

```bash
# APK Android
flutter build apk --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

## Segnalare bug

Apri una [Issue](https://github.com/ClaudioBecchis/volidicarta/issues) con:
- Descrizione del problema
- Passi per riprodurlo
- Piattaforma (Android/Windows/Web)
- Versione dell'app
- Screenshot (se applicabile)

## Pull Request

1. Fork il repository
2. Crea un branch (`feature/mia-feature`)
3. Fai commit delle modifiche
4. Assicurati che `flutter analyze` e `flutter test` passino
5. Apri una PR verso `main`

## Licenza

Contribuendo a questo progetto, accetti che i tuoi contributi saranno rilasciati sotto la stessa licenza del progetto.
