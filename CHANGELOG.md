# Changelog — Voli di Carta

Tutte le modifiche notevoli al progetto sono documentate in questo file.

---

## [1.3.19] - 2026-03-11

### Corretto
- **M-8**: `AuthService.login()` e `logout()` resettano ora `_isAdmin = false` — prevenuto bug per cui un utente admin che effettuava logout lasciava i permessi admin attivi per l'utente successivo
- **M-6**: `ReviewSyncService().delete()` in `my_reviews_screen.dart` è ora awaited — la cancellazione cloud non era più fire-and-forget
- **C-3 / C-7**: Aggiunta tabella `user_reviews` allo schema Supabase con RLS completa — il backup cloud delle recensioni private ora funziona
- **M-5**: Aggiunta colonna `is_admin` a `profiles` nello schema Supabase — `refreshAdminStatus()` ora legge correttamente il flag admin
- **I-3**: `getStatsByYear()` usa ora `end_date` (data di fine lettura) anziché `created_at` (data inserimento recensione)
- **I-4**: Testo privacy policy in `register_screen.dart` corretto — ora indica correttamente che i dati sono salvati sia su cloud che localmente
- **I-5**: `WishlistBook` in `SearchScreen._toggleWishlist()` ora include `bookGenre` — i libri aggiunti dalla ricerca conservano il genere
- **I-8**: Splash screen: init autenticazione e delay minimo ora eseguiti in parallelo con `Future.wait` — avvio leggermente più rapido

---

## [1.3.18] - 2026-03-10

### Migliorato
- **Ricerca per autore**: aggiunto selettore tipo ricerca (Tutto / Titolo / Autore) — la modalità Autore usa `inauthor:` su Google Books e `author=` su Open Library per risultati precisi
- **Suggerimenti autocomplete**: digitando almeno 3 caratteri, la ricerca per Autore suggerisce nomi reali da Open Library, quella per Titolo suggerisce titoli da Google Books
- **Hint contestuale**: il campo di ricerca mostra esempi diversi in base al tipo selezionato

---

## [1.3.17] - 2026-03-10

### Corretto
- **Fix admin Android**: `refreshAdminStatus()` ora chiamato dopo il login — il menu Admin appariva solo se l'utente riapriva l'app

---

## [1.3.16] - 2026-03-10

### Corretto
- **M-3**: `AuthService.register()` crea ora il profilo Supabase esplicitamente senza dipendere dal trigger DB
- **M-4**: Accesso admin ora basato su colonna `is_admin` nel DB (non più username hardcoded)
- **M-2**: `ReviewSyncService().upsert()` mostra snackbar se la sync cloud fallisce
- **C-2**: `write_review_screen.dart` usa `AuthService` come unico punto di verità per auth (rimosso uso di `SupabaseService` per login/logout check)
- **M-1**: `get_community_stats()` ora restituisce `offline_users` (aggiornata funzione SQL Supabase)
- **I-1**: Date lettura mostrate in formato `DD/MM/YYYY` invece di ISO raw
- **I-2**: `DbHelper` thread-safe — `_initFuture` previene doppia inizializzazione su web

---

## [1.3.15] - 2026-03-10

### Aggiunto
- **CRASH AUTOMATICO**: al riavvio dell'app dopo un crash, la segnalazione viene inviata automaticamente su GitHub (label `bug`, `crash-auto`) senza alcuna interazione utente
- **Copertura errori completa**: `runZonedGuarded` in `main.dart` cattura tutti gli errori async non gestiti oltre ai crash Flutter

---

## [1.3.14] - 2026-03-10

### Aggiunto
- **DONAZIONI**: Card "Supporta lo sviluppo" in Info App e Impostazioni — bottoni PayPal, Satispay e Ko-fi per supportare gli aggiornamenti futuri
- **SEGNALA BUG**: Dialog interno — l'utente descrive il problema e la segnalazione viene inviata automaticamente su GitHub senza aprire il browser
- **SUGGERISCI MIGLIORAMENTO**: Nuovo bottone in Info App — apre un dialog interno per inviare proposte direttamente su GitHub (sezione "enhancement")

---

## [1.3.13] - 2026-03-10

### Corretto
- **Crash fix**: `admin_users_screen` — crash se `username` è null nella ricerca
- **Crash fix**: `review_sync_service` — crash se `book_id` o `rating` sono null nel sync cloud
- **Crash fix**: `db_helper` — `int.parse` su anno null/non valido nelle statistiche per anno
- **Crash fix**: `forum_screen` — `setState` senza guard `mounted` in `_loadMore()`

---

## [1.3.8] - 2026-03-09

### Aggiunto
- **ADMIN**: Pannello "Utenti registrati" nel menu account (visibile solo all'admin) — lista utenti con username, data iscrizione, stato online (pallino verde), ricerca per nome

---

## [1.3.7] - 2026-03-09

### Aggiunto
- **AUTO-UPDATE**: Popup automatico all'avvio quando è disponibile una nuova versione
- **Android**: bottone "Scarica APK" apre direttamente il browser per il download
- **Windows**: download automatico + verifica SHA-256 + avvio installer (come prima)
- Refactoring: `UpdateService` + `UpdateDialog` riutilizzabili, codice duplicato rimosso da AboutScreen

---

## [1.3.6] - 2026-03-09

### Aggiunto
- **SYNC CLOUD**: Le recensioni vengono sincronizzate automaticamente su Supabase — accessibili da qualsiasi dispositivo con lo stesso account
- All'avvio: download automatico delle recensioni dal cloud (merge intelligente, vince la versione più recente)
- Ad ogni salvataggio/modifica/eliminazione: sync immediata in background su Supabase

---

## [1.3.5] - 2026-03-09

### Aggiunto
- **FORUM**: Sezione Forum nella Community — thread con categorie (Consigli, Discussioni, Domande, Off-topic), risposte, like; ogni utente può creare, eliminare i propri thread e rispondere
- **COMMUNITY STATS**: Banner iscritti/online nella schermata Community — mostra il numero totale di iscritti e quanti sono online negli ultimi 5 minuti (pallino verde)
- **PRESENCE TRACKING**: Heartbeat automatico `update_presence()` all'apertura della Community — tiene traccia degli utenti attivi

---

## [1.3.4] - 2026-03-09

### Aggiunto
- **BUG-REPORT**: Bottone "Segnala un Bug" nella schermata Info App — apre una issue GitHub precompilata con versione, piattaforma e ultimo crash registrato
- **BUG-REPORT**: Dialog di crash report all'avvio su Android e Windows — se l'app è crashata nella sessione precedente, propone di segnalarlo su GitHub

---

## [1.3.3] - 2026-03-09

### Corretto
- **BUG-NEW-A** 🔴: `AuthService._client` e `SupabaseService._client` resi nullable con guard `SupabaseConfig.isConfigured` — fix crash per tutti i 2 service che accedevano a `Supabase.instance` senza guard
- **BUG-NEW-B** 🟡: `CrashService` creato — handler globale Flutter (`FlutterError.onError` + `PlatformDispatcher.instance.onError`) che salva l'ultimo crash in `SharedPreferences`; installato in `main()` prima di `runApp()`
- **BUG-NEW-C** 🟠: `android:allowBackup="false"` aggiunto al `AndroidManifest.xml` principale — fix sicurezza Aikido; nota: richiede disinstallazione e reinstallazione dell'APK
- **BUG-NEW-D** 🟠: `android:networkSecurityConfig` esplicito aggiunto ai manifest debug e profile — fix warning Aikido "convalida non corretta del certificato SSL"

---

## [1.3.2] - 2026-03-09

### Corretto
- **BUG-Y** 🟢: CommunityScreen._load() e _loadMore() try/catch con fallback
- **BUG-Z** 🟢: rimosso community_auth_screen.dart (dead code)
- **BUG-I18N** 🟢: 10 stringhe hardcoded localizzate in 10 lingue (book_detail, write_review, community, my_reviews, wishlist)
- **BUG-DB** 🔴: db_helper su Windows usa getApplicationSupportDirectory() — fix SQLITE_CANTOPEN (code 14)

---

## [1.3.1] - 2026-03-09

### Corretto
- **BUG-V** 🔴: `LoginScreen.initState()` — `Supabase.instance` acceduto senza guard; ora avvolto in `if (SupabaseConfig.isConfigured)` — causa diretta del crash all'avvio su Android; `_authSub` cambiato da `late final` a nullable
- **BUG-V** 🔴: `RegisterScreen._register()` — `Supabase.instance.client.auth.currentSession` protetto da guard `SupabaseConfig.isConfigured`
- **BUG-V** 🔴: `main()` — `Supabase.initialize()` e `SettingsService.load()` avvolti in `try/catch`; `SplashScreen._init()` con guard `isConfigured` prima di `AuthService().isLoggedIn`
- **BUG-W** 🟡: `WishlistScreen._remove()` — `removeFromWishlist()` avvolto in `try/catch` con snackbar di errore
- **BUG-X** 🟢: `AboutScreen._checkUpdates()` — guard `SupabaseConfig.isConfigured` prima della chiamata HTTP; messaggio dedicato se Supabase non configurato
- `AndroidManifest.xml` — aggiunta voce `<queries>` per `share_plus` (Android 11+ richiede visibilità esplicita degli intent `ACTION_SEND`)

---

## [1.3.0] - 2026-03-08

### Corretto
- **BUG-J** 🔴: `SearchScreen._loadReviewed()` avvolto in `try/catch` — crash APK critico su Android release
- **BUG-K** 🟡: `WishlistScreen._load()` avvolto in `try/catch` con `_loading = false` fallback
- **BUG-L** 🟡: `MyReviewsScreen._load()` avvolto in `try/catch` con `_loading = false` fallback
- **BUG-M** 🟡: `BookDetailScreen._loadReview()` avvolto in `try/catch` — lo spinner non rimane più bloccato
- **BUG-N** 🟡: rimossi entrambi i bang operator `!` su `currentUser` in `WriteReviewScreen._save()` — sessione scaduta mostra messaggio e non crasha
- **BUG-O** 🟡: `SearchScreen._toggleWishlist()` avvolto in `try/catch` — snackbar di errore in caso di fallimento SQLite
- **BUG-P** 🟢: `MyReviewsScreen._deleteReview()` avvolto in `try/catch` con snackbar di errore
- **BUG-Q** 🟢: `BookDetailScreen._deleteReview()` avvolto in `try/catch` con snackbar di errore
- **BUG-R** 🟢: `WriteReviewScreen._save()` — validazione `endDate >= startDate` prima del salvataggio

### Migliorato
- **BUG-S** 🟢: `StatsScreen` — 5 stringhe hardcoded localizzate via nuovi tasti `app_strings.dart`: `avgRatingLabel`, `mostReadGenres`, `booksByYear`, `writeReviewsForStats`
- **BUG-T** 🟢: `WishlistScreen` AppBar usa `S.of(context).toRead` invece di `'Da Leggere'` hardcoded
- **BUG-U** 🟢: `AboutScreen` legge la versione a runtime da `package_info_plus` — nessun più disallineamento manuale tra `pubspec.yaml` e `_currentVersion`

---

## [1.2.0] - 2026-03-08

### Aggiunto
- **Filtro lingua con ChoiceChip** (IMP-06): nella schermata Cerca, tre chip selezionabili 🇮🇹 ITA / 🇬🇧 ENG / 🌐 Tutti sostituiscono il vecchio toggle booleano; il filtro si applica sia a Google Books che a Open Library
- **Condivisione nativa** (IMP-NEW-01): il pulsante Condividi nel dettaglio libro usa ora `share_plus` per aprire il foglio di condivisione nativo del sistema (era: copia negli appunti)
- **Test reali con sqflite_ffi** (IMP-05): `db_helper_test.dart` con 10 test su statistiche DB e semver comparison, eseguibili su desktop senza dispositivo

### Migliorato
- **i18n completa** (BUG-12): tutte le stringhe UI di home, ricerca, recensioni, community, wishlist e statistiche ora passano da `S.of(context)` con 10 lingue supportate; aggiunti ~15 nuovi tasti in `app_strings.dart`
- **Dark mode profonda** (NEW-E): colori decorativi `0xFFD6EAF8` e `0xFFEAF4FC` nelle card placeholder sostituiti con `AppColors.chipBg(ctx)` e `AppColors.chipBgLight(ctx)` — dark-aware in book_card, book_detail, community, my_reviews, home e wishlist

### Corretto
- **BUG-G** (Windows UAC timing): aggiunto `Future.delayed(500ms)` tra `Process.start()` e `SystemNavigator.pop()` — il prompt UAC non viene più orfano
- **BUG-H** (crash APK — Dashboard): `_DashboardTab._load()` avvolto in `try/catch` — eccezioni DB non crashano l'app su Android release
- **BUG-I** (crash APK — Statistiche): `StatsScreen._load()` avvolto in `try/catch` con stato fallback `total=0`
- **BookApiService.search()**: accetta ora il parametro `langRestrict` (default `'it'`) passato dalla SearchScreen; il fallback Open Library usa il codice lingua corrispondente (`ita`/`eng`)
- **SearchScreen**: rimosso campo `_italianOnly` obsoleto; `_buildResults()` usa `_langFilter` coerente con il resto dello stato

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
