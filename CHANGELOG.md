# Changelog — Voli di Carta

Tutte le modifiche notevoli al progetto sono documentate in questo file.

---

## [1.1.0] - 2026-03-08

### Aggiunto
- **Dark mode completa**: tutte le 12 schermate ora rispettano il tema scuro/chiaro del sistema — nessuna schermata rimane con lo sfondo azzurro fisso
- **Statistiche per genere**: nuova card "Generi più letti" con barre proporzionali (top 8 generi)
- **Statistiche per anno**: nuova card "Libri per anno" con barre orizzontali (ultimi 5 anni)
- **Ricerca e ordinamento Wishlist**: barra di ricerca per titolo/autore + menu ordinamento (data, titolo, autore)
- **Pulsante Condividi su dettaglio libro**: copia titolo e autore negli appunti con un tap
- **`app_colors.dart`**: centralizzazione colori — `AppColors.screenBg(context)`, `primary`, `secondary`, `amber`, `purple`

### Corretto
- **NEW-B**: `CommunityScreen._load()` e `_loadMore()` — aggiunto `if (!mounted) return` prima di ogni `setState` iniziale
- **NEW-C**: `StatsScreen` — aggiunto `RefreshIndicator` con `AlwaysScrollableScrollPhysics` (pull-to-refresh)
- **NEW-D**: cast `avg` esplicito in `home_screen.dart` — `(stats['avg'] as num).toDouble()` coerente con `stats_screen.dart`

---

## [1.0.9] - 2026-03-08

### Aggiunto
- **Ultimi 3 libri letti in Dashboard**: sezione "Ultimi letti" con copertina, titolo e voto — tap per aprire il dettaglio
- **Terzo KPI Dashboard — Da leggere**: contatore wishlist accanto a "Libri letti" e "Media voti"

### Migliorato
- **Confronto versioni semver**: l'aggiornamento automatico ora usa un confronto semantico corretto (1.0.10 > 1.0.9) invece di semplice disuguaglianza stringa
- **Chiusura app post-update sicura**: il database viene chiuso prima di avviare l'installer (`DbHelper.close()` + `SystemNavigator.pop()` al posto di `exit(0)` brutale)
- **toggleLike immutabile**: `PublicReview.toggleLike` usa ora `copyWith` e restituisce un nuovo oggetto invece di mutare lo stato direttamente — il cuore si aggiorna correttamente nella lista senza pull-to-refresh
- **AVG SQLite cast sicuro alla sorgente**: il cast `num → double` avviene in `DbHelper.getStats()`, tutti i chiamanti ricevono già `double?`
- **Navigazione Dashboard via callback**: `_DashboardTab` usa `onTabChange` callback invece di `findAncestorStateOfType` (anti-pattern)
- **AddBookManualScreen**: usa `push` invece di `pushReplacement` — l'utente può tornare al form con il tasto indietro da WriteReviewScreen

### Corretto
- **BUG-09**: `_onUpgrade` usava `else if` — utenti che saltavano versioni (es. v3→v5) non ricevevano le migrazioni intermediate; ora usa `if` sequenziali indipendenti
- **BUG-10**: `_saving` in WriteReviewScreen non veniva resettato se si verificava un'eccezione; ora usa `finally` garantendo sempre il reset
- **BUG-13**: `_load()` in MyReviewsScreen sovrascriveva `_filtered` perdendo i filtri attivi; ora chiama `_applyFilter()` dopo il reload
- **BUG-06**: mutazione diretta su `PublicReview.isLikedByMe` e `likesCount`; ora modello immutabile con `copyWith`

---

## [1.0.8] - 2026-03-08

### Aggiunto
- **Paginazione infinita nella Community**: il feed carica automaticamente altri 20 risultati quando si scorre fino in fondo, senza ricaricare tutta la lista
- **Elimina dalla Community**: pulsante per rimuovere la propria recensione dalla community direttamente dalla schermata di dettaglio (la recensione rimane nel diario personale)
- **Conferma logout**: dialogo di conferma prima di disconnettersi dall'account community
- **Utility date condivisa**: funzione `formatDateForDisplay()` centralizzata in `utils/date_format.dart` usata in tutta l'app

### Migliorato
- **Accessibilità stelle**: widget `StarRatingDisplay` e `StarRatingPicker` ora includono etichette semantiche per screen reader e area di tocco minima 48dp per ogni stella
- **Cache ricerche con scadenza (TTL 30 min)**: le ricerche in cache ora scadono dopo 30 minuti, evitando risultati obsoleti
- **Memoizzazione raggruppamento recensioni**: il raggruppamento per autore/genere nella lista recensioni è ora calcolato una sola volta per stato, migliorando le performance su grandi librerie
- **Validazione URL copertina**: nel form "Aggiungi libro manualmente", l'URL copertina viene validato (deve iniziare con `http://` o `https://`)
- **Risoluzione locale fallback**: se la lingua di sistema non è supportata, l'app usa l'italiano come fallback invece di causare errori
- **Verifica integrità aggiornamento (SHA-256)**: l'installer scaricato viene verificato tramite checksum prima dell'installazione (richiede campo `sha256_checksum` nella tabella Supabase)
- **Gestione errori salvataggio recensione**: errori durante il salvataggio mostrano un messaggio rosso dettagliato invece di bloccare silenziosamente l'interfaccia

### Corretto
- **BUG-01**: memory leak `StreamSubscription` su `LoginScreen` — ora cancellata correttamente nel `dispose()`
- **BUG-02**: `TapGestureRecognizer` su `RegisterScreen` non veniva deallocato — ora gestito nel `dispose()`
- **BUG-03**: `SQLite AVG()` restituisce `num` invece di `double` — cast esplicito in `HomeScreen` e `StatsScreen`
- **BUG-04**: date salvate in formato `dd/MM/yyyy` invece di ISO 8601 — ora sempre `YYYY-MM-DD` internamente, con conversione per la UI
- **BUG-07**: tentativo di login con username (ramo morto) rimosso da `AuthService`
- **BUG-08**: dopo la registrazione, se la sessione è già attiva, navigazione diretta a `HomeScreen`

### Rimosso
- Dipendenza `flutter_rating_bar` rimossa (non usata, sostituita da widget personalizzato)

---

## [1.0.6] - 2026-03-08

### Migliorato
- **Descrizione libri Open Library**: caricata automaticamente dalla Works API quando si apre il dettaglio libro
- **Pulsante anteprima**: mostra "Apri su Open Library" per i libri provenienti da Open Library
- **Testo ricerca**: colore scuro forzato nella casella di ricerca per leggibilità in qualsiasi tema

---

## [1.0.5] - 2026-03-08

### Migliorato
- **Fallback automatico su Open Library**: se Google Books restituisce errore 429 (limite raggiunto), l'app cerca automaticamente su Open Library (Internet Archive) senza mostrare errori all'utente

---

## [1.0.4] - 2026-03-08

### Corretto
- **Fix crash Windows**: ripristinato approccio originale con import diretti e check runtime della piattaforma; i conditional imports introdotti in v1.0.3 causavano crash all'avvio su Windows

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
