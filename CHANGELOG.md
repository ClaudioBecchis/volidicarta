# Changelog — Voli di Carta

Tutte le modifiche notevoli al progetto sono documentate in questo file.

---

## [1.0.3] - 2026-03-08

### Corretto
- **Fix crash Android all'avvio**: rimossi import incompatibili (`sqflite_common_ffi_web`) dall'APK Android tramite conditional imports per piattaforma
- **R8 minification disabilitato**: evita che il compilatore Android rimuova codice necessario a runtime
- **ProGuard rules** aggiunte per Flutter, Supabase, SQLite, Kotlin

---

## [1.0.2] - 2026-03-07

### Migliorato
- **Anti-429**: cache in memoria delle ricerche (stessa query non chiama l'API due volte)
- **Rate limiting**: intervallo minimo di 1.5s tra chiamate senza chiave API
- **Retry automatico**: in caso di errore 429, l'app attende 4 secondi e riprova automaticamente

---

## [1.0.1] - 2026-03-07

### Aggiunto
- **Aggiornamento automatico**: pulsante "Installa Aggiornamento" che scarica l'installer direttamente dall'app con barra di avanzamento, mostra dialogo di conferma, avvia il wizard e chiude l'app
- **Supporto chiave API Google Books**: configurabile in `lib/config/app_config.dart` per aumentare il limite di ricerche da ~100 a 1000 al giorno
- **Lista "Da Leggere"**: wishlist di libri da leggere in futuro, accessibile dalla quarta scheda
- **Anteprima copertina HD**: copertina ingrandibile a schermo intero con pinch-to-zoom nella scheda dettaglio libro
- **Pulsante Anteprima Google Books**: apre l'anteprima del libro nel browser direttamente dalla scheda dettaglio
- **Date lettura**: campi "Inizio lettura" e "Fine lettura" separati nella schermata di scrittura recensione
- **Supporto Web**: app disponibile online su GitHub Pages con SQLite via WebAssembly

### Migliorato
- Messaggio di errore dettagliato per errore 429 (troppo traffico su Google Books)
- Schermata "Info App" convertita in StatefulWidget per supportare il controllo aggiornamenti
- Visualizzazione date lettura nella scheda dettaglio e nella lista recensioni
- Registrazione diretta senza dialogo di conferma email

### Corretto
- Errore tipo `List<dynamic>` vs `List<Book>` nel servizio API
- Import `dart:io` incompatibile con web sostituito con `flutter/foundation.dart`
- Riferimenti al vecchio campo `readDate` aggiornati a `startDate`/`endDate`

---

## [1.0.0] - 2026-03-06

### Prima versione pubblica

- Ricerca libri tramite Google Books API
- Scrittura e modifica recensioni con valutazione a stelle (1–5)
- Organizzazione per autore e genere
- Statistiche di lettura personali
- Community: condivisione recensioni, like, feed pubblico
- Autenticazione tramite Supabase (email + password)
- Dati locali su SQLite (Windows e Android)
- Supporto Windows (EXE + installer InnoSetup) e Android (APK)
- Icona personalizzata generata con flutter_launcher_icons
