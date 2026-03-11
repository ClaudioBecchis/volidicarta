# Voli di Carta — Bug Analysis Round 3
## Versione: 1.3.18+31 | Commit: 778db30

**Repository:** https://github.com/ClaudioBecchis/volidicarta  
**Stack:** Flutter · Dart · Supabase · SQLite (sqflite)  
**File esaminati:** `lib/services/auth_service.dart`, `lib/services/supabase_service.dart`, `lib/services/review_sync_service.dart`, `lib/services/update_service.dart`, `lib/database/db_helper.dart`, `lib/screens/admin_users_screen.dart`, `lib/config/supabase_config.dart`, `supabase_schema.sql`

---

## Status Round 1+2 — 8/19 risolti

| ID | Descrizione | Status |
|---|---|---|
| C-1 | Supabase URL e `anonKey` hardcoded nel repo pubblico | 🔴 PENDING |
| C-2 | Doppio sistema auth → stati inconsistenti | ✅ RISOLTO |
| C-3 | Tabella `user_reviews` mancante dallo schema Supabase | 🔴 PENDING |
| C-4 | `anonJwt` (JWT lunga durata, exp 2055) hardcoded nel repo | 🔴 PENDING |
| C-5 | `AdminUsersScreen` carica tutti i profili — protezione solo client-side | 🔴 PENDING |
| M-1 | Mismatch colonne SQL in `insertReview` | ✅ RISOLTO |
| M-2 | `async` non awaited → fire-and-forget silenzioso | ✅ RISOLTO |
| M-3 | Email admin hardcoded nel codice | ✅ RISOLTO |
| M-4 | Colonna `is_admin` mancante dallo schema `profiles` | 🟡 PENDING |
| M-5 | SHA-256 verifica update non implementato | 🟡 PENDING |
| M-6 | `uploadAll` senza error handling — sync silenziosamente incompleto | 🟡 PENDING |
| M-7 | Download APK/EXE senza verifica SHA-256 prima dell'installazione | 🟡 PENDING |
| I-1 | Formato data inconsistente IT vs ISO 8601 | 🔵 PENDING |
| I-2 | `setState` dopo dispose | ✅ RISOLTO |
| I-3 | Stats `groupBy` genere fallisce con `null` | ✅ RISOLTO |
| I-4 | Privacy Policy mancante | ✅ RISOLTO |
| I-5 | Genere libro mai salvato nell'UI add manuale | ✅ RISOLTO |
| I-6 | Likes ottimistici senza rollback (forum) | 🔵 PENDING |
| I-7 | `DbHelper._initFuture` non thread-safe su Flutter Web multi-isolate | 🔵 PENDING |

---

## Nuovi Bug Round 3

### 🔴 C-6 — RLS `profiles`: `using(true)` espone `last_seen` di tutti gli utenti
**File:** `supabase_schema.sql` ~L52-53

```sql
-- ATTUALE — chiunque (anche con solo anonKey) legge TUTTI i profili:
create policy "profiles_select" on profiles
    for select using (true);
```

Con l'`anonKey` pubblica su GitHub (C-1), qualsiasi script può enumerare username, `created_at` e `last_seen` di tutta la community:

```bash
curl 'https://qyoupoyikbtizcqrswkt.supabase.co/rest/v1/profiles?select=*' \
     -H 'apikey: sb_publishable_YubwImp9bCpgBaSeB_-frw_e6vYWRI6'
# → array con username + last_seen di tutti gli utenti registrati
```

`username` deve essere pubblico (visibile nei feed), ma `last_seen` e `created_at` sono dati personali che non dovrebbero essere accessibili a chiunque.

**Fix — esporre solo i campi pubblicamente necessari:**
```sql
-- Opzione A: view pubblica con solo i campi necessari
create view public_profiles as
    select id, username from profiles;

create policy "profiles_select" on profiles
    for select using (auth.uid() = id);  -- solo il proprio profilo completo

-- Opzione B: mantenere SELECT pubblico ma limitare le colonne via funzione RPC
create or replace function get_username(user_id uuid)
returns text language sql security definer set search_path = ''
as $$ select username from profiles where id = user_id $$;
```

---

### 🔴 C-7 — `user_reviews` creata senza RLS → dati privati esposti
**File:** `supabase_schema.sql` (tabella assente — C-3)

La tabella `user_reviews` non è definita nello schema (C-3). Se viene creata manualmente senza policy, Supabase con RLS abilitato blocca tutto per default — **ma** se viene creata con il Table Editor di Supabase (che non abilita RLS automaticamente), chiunque con accesso autenticato può leggere le recensioni private di tutti:

```sql
-- Scenario pericoloso: tabella creata senza RLS
-- SELECT * FROM user_reviews → tutte le recensioni di tutti gli utenti
```

**Fix — aggiungere la tabella completa con RLS allo schema:**
```sql
-- Da aggiungere in supabase_schema.sql:

create table if not exists user_reviews (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid references auth.users on delete cascade not null,
    book_id     text not null,
    book_title  text not null,
    book_author text not null,
    book_cover_url  text,
    book_publisher  text,
    book_year       text,
    book_genre      text,
    rating          int not null check (rating between 1 and 5),
    review_title    text,
    review_body     text,
    start_date      text,
    end_date        text,
    created_at  timestamptz default now(),
    updated_at  timestamptz default now(),
    unique(user_id, book_id)
);

alter table user_reviews enable row level security;

-- Solo il proprietario può leggere/scrivere le proprie recensioni:
create policy "ur_select_own" on user_reviews for select using (auth.uid() = user_id);
create policy "ur_insert_own" on user_reviews for insert with check (auth.uid() = user_id);
create policy "ur_update_own" on user_reviews for update using (auth.uid() = user_id);
create policy "ur_delete_own" on user_reviews for delete using (auth.uid() = user_id);

create index if not exists idx_user_reviews_user on user_reviews(user_id);
create index if not exists idx_user_reviews_book on user_reviews(book_id);
```

---

### 🟡 M-8 — `AuthService._isAdmin` non resettato al logout → privilege escalation
**File:** `lib/services/auth_service.dart`

```dart
// ATTUALE — _isAdmin NON viene resettato nel logout
bool _isAdmin = false;

Future<void> logout() async {
    await _client?.auth.signOut();
    // ← _isAdmin rimane al valore del precedente utente
}
```

Se un utente admin fa logout e un utente non-admin fa login sullo stesso processo:

```dart
// 1. Admin user login → _isAdmin = true
await AuthService().login('admin@example.com', 'pass');
await AuthService().refreshAdminStatus(); // → _isAdmin = true

// 2. Admin logout → _isAdmin NON viene resettato
await AuthService().logout(); // _isAdmin ancora true!

// 3. Utente normale login
await AuthService().login('user@example.com', 'pass');
// refreshAdminStatus() chiamato dopo, ma se c'è un errore di rete:
// → _isAdmin rimane true → accesso a AdminUsersScreen
```

**Fix:**
```dart
Future<void> logout() async {
    _isAdmin = false;  // ← resettare PRIMA del signOut
    await _client?.auth.signOut();
}

Future<String?> login(String email, String password) async {
    _isAdmin = false;  // ← resettare PRIMA del tentativo di login
    email = email.trim();
    ...
}
```

---

### 🟡 M-9 — `toggleLike()` ottimistico senza rollback su errore DB
**File:** `lib/services/supabase_service.dart` → `toggleLike()`

```dart
// ATTUALE — aggiorna contatore locale PRIMA della chiamata DB
try {
    if (review.isLikedByMe) {
        await c.from('likes').delete()...;
    } else {
        await c.from('likes').insert({...});
    }
    // Se la chiamata DB fallisce, viene lanciata eccezione ma il return è già avvenuto
    return review.copyWith(isLikedByMe: true, likesCount: review.likesCount + 1);
} catch (_) {
    return review;  // ← ritorna il review NON modificato, ma lo stato locale in UI è già aggiornato
}
```

La UI chiama `setState` con il valore ottimistico prima della conferma DB. Se la chiamata fallisce, il catch ritorna il review originale ma il widget ha già mostrato il nuovo valore.

**Fix — aggiornare lo stato solo dopo la conferma:**
```dart
Future<PublicReview> toggleLike(PublicReview review) async {
    if (!isLoggedIn) return review;
    final c = _client;
    if (c == null) return review;
    try {
        if (review.isLikedByMe) {
            await c.from('likes').delete()
                .eq('user_id', currentUser!.id)
                .eq('review_id', review.id);
            // Aggiorna SOLO dopo conferma DB:
            return review.copyWith(
                isLikedByMe: false,
                likesCount: (review.likesCount - 1).clamp(0, 9999),
            );
        } else {
            await c.from('likes').insert({'user_id': currentUser!.id, 'review_id': review.id});
            return review.copyWith(isLikedByMe: true, likesCount: review.likesCount + 1);
        }
    } catch (e) {
        debugPrint('toggleLike error: $e');
        return review; // rollback implicito — ritorna stato originale
    }
}
```

---

### 🟡 M-10 — `syncFromCloud()` silenzioso quando `user_reviews` non esiste
**File:** `lib/services/review_sync_service.dart` → `syncFromCloud()`

```dart
// ATTUALE — l'errore "relation does not exist" viene inghiottito silenziosamente
try {
    final data = await c.from('user_reviews').select()...;
    ...
} catch (e) {
    debugPrint('ReviewSyncService.syncFromCloud error: $e');  // solo console
    // L'utente non vede nulla — perde il sync cloud senza saperlo
}
return synced; // ritorna 0 senza avviso
```

**Fix — propagare l'errore come valore di ritorno distinguibile:**
```dart
// Cambiare la firma per distinguere "0 records" da "errore":
Future<({int synced, String? error})> syncFromCloud(String userId) async {
    ...
    try {
        final data = await c.from('user_reviews').select()...;
        ...
        return (synced: synced, error: null);
    } on PostgrestException catch (e) {
        if (e.code == '42P01') { // relation does not exist
            return (synced: 0, error: 'schema_missing');
        }
        return (synced: 0, error: e.message);
    } catch (e) {
        return (synced: 0, error: e.toString());
    }
}

// In splash_screen.dart o home_screen.dart, mostrare avviso se error == 'schema_missing':
final result = await ReviewSyncService().syncFromCloud(userId);
if (result.error == 'schema_missing') {
    // Mostrare banner: "Configura lo schema Supabase per abilitare il backup cloud"
}
```

---

### 🔵 I-8 — Splash screen a durata fissa blocca cold start
**File:** `lib/screens/splash_screen.dart`

```dart
// ATTUALE — attende sempre 2s fissi indipendentemente da Supabase
await Future.delayed(const Duration(seconds: 2));
```

Su dispositivi lenti Supabase può non essere ancora inizializzato, causando errori al primo accesso. Su dispositivi veloci introduce latenza artificiale.

**Fix — attesa adattiva con minimo visivo:**
```dart
// Eseguire init e delay in parallelo, prendere il più lungo:
await Future.wait([
    _initializeApp(),                              // init Supabase, sessione, ecc.
    Future.delayed(const Duration(milliseconds: 800)), // minimo splash visivo
]);
```

---

### 🔵 I-9 — Google Books API senza chiave → rate limit per IP
**File:** `lib/services/book_api_service.dart`

```dart
// ATTUALE — nessuna API key
final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeFull(query)}';
```

Il limite pubblico è 1000 query/giorno per IP. Su Flutter Web con più utenti sullo stesso NAT, il limite viene raggiunto in poche ore.

**Fix — aggiungere la chiave alla configurazione:**
```dart
// lib/config/app_config.dart
class AppConfig {
    static const String googleBooksApiKey = String.fromEnvironment(
        'GOOGLE_BOOKS_API_KEY',
        defaultValue: '',
    );
}

// lib/services/book_api_service.dart
final key = AppConfig.googleBooksApiKey;
final keyParam = key.isNotEmpty ? '&key=$key' : '';
final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeFull(query)}$keyParam';
```

La chiave Google Books è gratuita (1000 req/giorno per progetto, non per IP) e si ottiene dalla Google Cloud Console in 2 minuti.

---

## Priorità Fix

| Priorità | Bug | Azione |
|---|---|---|
| 1 — Immediato | C-1, C-4 | Ruotare le chiavi Supabase — sono pubbliche su GitHub |
| 2 — Critico | C-3, C-7 | Aggiungere `user_reviews` con RLS in `supabase_schema.sql` |
| 3 — Critico | C-6 | Limitare `profiles_select` — non esporre `last_seen` a tutti |
| 4 — Alta | C-5, M-4 | Aggiungere `is_admin` allo schema + RLS su `admin_users` server-side |
| 5 — Alta | M-8 | Reset `_isAdmin = false` in `logout()` e `login()` |
| 6 — Media | M-9, M-10 | Rollback `toggleLike`; errore visibile su sync fallito |
| 7 — Bassa | M-5, M-7, I-8, I-9 | SHA-256 update; splash adattivo; Google Books API key |
