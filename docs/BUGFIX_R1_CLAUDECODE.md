# Voli di Carta — Analisi Bug e Issue
## Report per Claude Code — Round 1

**Data:** 2026-03-10  
**Repository:** https://github.com/ClaudioBecchis/volidicarta  
**Versione analizzata:** 1.3.15+28  
**Stack:** Flutter/Dart, Supabase, SQLite (sqflite), Google Books API

---

## RIEPILOGO

| ID | Gravità | File | Descrizione |
|---|---|---|---|
| C-1 | 🔴 Critico | `supabase_config.dart` | Chiavi Supabase hardcoded nel repo pubblico |
| C-2 | 🔴 Critico | `auth_service.dart` / `supabase_service.dart` | Doppio sistema auth — stati inconsistenti |
| M-1 | 🟡 Media | `supabase_schema.sql` + `supabase_service.dart` | `get_community_stats()` non restituisce `offline_users` e `anon_online` |
| M-2 | 🟡 Media | `write_review_screen.dart` | `ReviewSyncService().upsert()` non awaited — errori cloud silenziosi |
| M-3 | 🟡 Media | `supabase_service.dart` vs `auth_service.dart` | Registrazione doppia: un path crea il profilo, l'altro no |
| M-4 | 🟡 Media | `home_screen.dart` | Accesso admin hardcoded su username "claudio" |
| I-1 | 🔵 Bassa | `book_detail_screen.dart` | Date lettura mostrate in formato ISO raw nella recensione |
| I-2 | 🔵 Bassa | `db_helper.dart` | Singleton `DbHelper` non thread-safe su web |

---

## 🔴 C-1 — Chiavi Supabase hardcoded nel repository pubblico

**File:** `src/lib/config/supabase_config.dart`

**Problema:**  
Le credenziali Supabase sono committate in chiaro nel codice sorgente su un repository GitHub **pubblico**:

```dart
static const String url = 'https://qyoupoyikbtizcqrswkt.supabase.co';
static const String anonKey = 'sb_publishable_YubwImp9...';
static const String anonJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

La `anonKey` è una chiave pubblica quindi teoricamente sicura se le RLS Supabase sono configurate correttamente — ma la `anonJwt` è un JWT a lunga scadenza (exp: 2088) che potrebbe dare accesso prolungato. Soprattutto, il pattern è sbagliato: chiunque forka il repo eredita le credenziali di produzione.

**Fix:**
1. Usare variabili d'ambiente o un file `supabase_config.local.dart` escluso da `.gitignore`
2. Il file `supabase_config.example.dart` esiste già — usarlo come template e rimuovere le credenziali reali dal file committato

```dart
// supabase_config.dart — versione sicura da committare
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String anonJwt = String.fromEnvironment('SUPABASE_JWT', defaultValue: '');
  
  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty && url.startsWith('https://');
}
```

In alternativa, mantenere un file `supabase_config.local.dart` (escluso da `.gitignore`) con le credenziali reali e importarlo solo in build locali.

---

## 🔴 C-2 — Doppio sistema di autenticazione con stati inconsistenti

**File:** `src/lib/services/auth_service.dart` + `src/lib/services/supabase_service.dart`

**Problema:**  
Esistono due service che gestiscono l'autenticazione Supabase in parallelo:

| Operazione | `AuthService` | `SupabaseService` |
|---|---|---|
| Login | `login(email, pass)` | `signIn(email, pass)` |
| Registrazione | `register(user, email, pass)` | `signUp(user, email, pass)` |
| Utente corrente | `currentUser` → `User` custom | `currentUser` → `SupabaseUser` |
| Logout | `logout()` | `signOut()` |

**In `write_review_screen.dart`** vengono usati entrambi nella stessa schermata:
```dart
// uid locale da AuthService
final uid = AuthService().currentUser?.id;

// uid Supabase da SupabaseService per pubblicare
final supaUid = SupabaseService().currentUser?.id;
if (_sharePublic && SupabaseService().isLoggedIn && supaUid != null) { ... }
```

Poiché entrambi accedono a `Supabase.instance.client.auth.currentUser`, in questo caso specifico funzionano, ma il design è fragile: in `login_screen.dart` viene chiamato solo `AuthService().login()`, lasciando `SupabaseService` come wrapper ridondante. Se in futuro uno dei due viene aggiornato senza l'altro, si rompe la coerenza.

**Fix:** Rimuovere i metodi di autenticazione da `SupabaseService` e usare solo `AuthService` per login/register/logout. `SupabaseService` deve occuparsi solo di community (feed, like, forum, presenza).

```dart
// SupabaseService — rimuovere:
// - signUp()
// - signIn()
// - signOut()
// - _translateAuthError()
// Mantenere solo: fetchFeed, publishReview, toggleLike, fetchProfile, updatePresence, getCommunityStats, ecc.
```

In `write_review_screen.dart`, sostituire:
```dart
// PRIMA (inconsistente)
final supaUid = SupabaseService().currentUser?.id;
if (_sharePublic && SupabaseService().isLoggedIn && supaUid != null)

// DOPO (unico punto di verità)
final uid = AuthService().currentUser?.id;
if (_sharePublic && AuthService().isLoggedIn && uid != null)
```

---

## 🟡 M-1 — `get_community_stats()` non restituisce `offline_users` e `anon_online`

**File:** `supabase_schema.sql` + `src/lib/services/supabase_service.dart`

**Problema:**  
La funzione SQL restituisce solo 2 campi:
```sql
select json_build_object(
  'total_users', (select count(*) from profiles),
  'online_users', (select count(*) from profiles where last_seen > now() - interval '5 minutes')
);
```

Ma `getCommunityStats()` in Dart si aspetta 4 campi:
```dart
totalUsers: (m['total_users'] as num?)?.toInt() ?? 0,
onlineUsers: (m['online_users'] as num?)?.toInt() ?? 0,
offlineUsers: (m['offline_users'] as num?)?.toInt() ?? 0,  // ← sempre 0
anonOnline: (m['anon_online'] as num?)?.toInt() ?? 0,       // ← sempre 0
```

La UI mostra sempre "0 offline" e "0 visitatori" perché i campi non esistono nella risposta SQL.

**Fix — aggiornare la funzione SQL su Supabase:**
```sql
create or replace function get_community_stats()
returns json as $$
  select json_build_object(
    'total_users',   (select count(*) from profiles),
    'online_users',  (select count(*) from profiles 
                      where last_seen > now() - interval '5 minutes'),
    'offline_users', (select count(*) from profiles 
                      where last_seen is null 
                         or last_seen <= now() - interval '5 minutes'),
    'anon_online',   0  -- placeholder, richiede tabella anon_presence separata
  );
$$ language sql security invoker set search_path = '';
```

Se si vuole implementare `anon_online` davvero, serve aggiungere al schema una tabella `anon_presence` con `session_id`, `platform`, `last_seen` e l'RPC `update_anon_presence` (già chiamata da Dart ma non presente nello schema SQL).

---

## 🟡 M-2 — `ReviewSyncService().upsert()` fire-and-forget: errori cloud silenziosi

**File:** `src/lib/screens/write_review_screen.dart` (righe ~130 e ~150)

**Problema:**  
```dart
await DbHelper().updateReview(review);
ReviewSyncService().upsert(review);   // ← manca await, e non c'è await neanche su uploadAll

// ...

await DbHelper().insertReview(review);
ReviewSyncService().upsert(review);   // ← stesso problema
```

Se la sync Supabase fallisce (rete assente, token scaduto, ecc.) l'errore viene ingoiato silenziosamente in `upsert()` con solo un `debugPrint`. L'utente non viene informato che la recensione non è stata sincronizzata con il cloud.

**Fix — aggiungere `await` e feedback all'utente:**

Non è necessario bloccare il salvataggio locale per un errore cloud, ma almeno informare l'utente:

```dart
await DbHelper().insertReview(review);
// Sync cloud in background — mostra warning se fallisce
ReviewSyncService().upsert(review).catchError((e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recensione salvata localmente — sync cloud fallita'),
        duration: Duration(seconds: 3),
      ),
    );
  }
});
```

---

## 🟡 M-3 — Registrazione doppia: `AuthService` non crea il profilo Supabase

**File:** `src/lib/services/auth_service.dart` vs `src/lib/services/supabase_service.dart`

**Problema:**  
`SupabaseService.signUp()` crea esplicitamente il profilo:
```dart
await c.from('profiles').upsert({'id': res.user!.id, 'username': username});
```

`AuthService.register()` invece si affida solo al trigger:
```dart
// Il profilo viene creato automaticamente dal trigger su auth.users.
```

Ma il trigger `on auth.users` **non è presente nello schema SQL committato**. Se il trigger non è configurato sul progetto Supabase, gli utenti registrati tramite `AuthService` non avranno un profilo in `profiles`, causando errori nelle query di community che fanno JOIN con `profiles`.

**Fix:** Aggiungere la creazione del profilo in `AuthService.register()`:
```dart
Future<String?> register(String username, String email, String password) async {
  // ...
  final res = await c.auth.signUp(email: email, password: password, data: {'username': username});
  if (res.user == null) return 'Registrazione fallita. Riprova.';
  
  // Crea profilo esplicitamente (non dipendere dal trigger)
  try {
    await c.from('profiles').upsert({
      'id': res.user!.id,
      'username': username,
    });
  } catch (e) {
    debugPrint('Profilo creation error: $e');
  }
  return null;
}
```

E aggiungere il trigger nello schema SQL come fallback:
```sql
-- Trigger per creare profilo automaticamente al signup
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'username')
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = '';

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
```

---

## 🟡 M-4 — Accesso admin hardcoded per username "claudio"

**File:** `src/lib/screens/home_screen.dart` (riga ~220)

**Problema:**  
```dart
if (user != null && user.username.toLowerCase() == 'claudio')
  const PopupMenuItem(
    value: 'admin_users',
    child: ...,
  ),
```

Chiunque si registri con username "claudio" ottiene accesso alla schermata `AdminUsersScreen`. Non è un vero sistema di permessi.

**Fix:** Usare un campo `is_admin` nella tabella `profiles` Supabase + verificarlo lato server tramite RLS policy o RPC:

```sql
-- Aggiungere al schema
alter table profiles add column if not exists is_admin boolean default false;
```

```dart
// Caricare il profilo al login e caching locale
bool get isAdmin => _cachedProfile?['is_admin'] == true;
```

In alternativa, come fix minimo immediato, usare l'UUID dell'utente admin invece dello username:
```dart
// Hardcodato ma almeno non modificabile dall'utente
static const _adminId = 'UUID-DELL-UTENTE-CLAUDIO';
if (user != null && user.id == _adminId)
```

---

## 🔵 I-1 — Date lettura mostrate in formato ISO raw nella `_ReviewCard`

**File:** `src/lib/screens/book_detail_screen.dart` (classe `_ReviewCard`, riga ~420)

**Problema:**  
```dart
Text(
  review.startDate != null && review.endDate != null
    ? '${review.startDate} → ${review.endDate}'   // ← ISO: "2025-12-01 → 2026-01-15"
    : review.endDate != null
      ? 'Finito il ${review.endDate}'              // ← ISO: "Finito il 2026-01-15"
      : 'Iniziato il ${review.startDate}',
)
```

Le date vengono mostrate in formato ISO `2025-12-01` invece di `01/12/2025`. Il metodo `_displayDate()` esiste già in `WriteReviewScreen` ma non viene usato qui.

**Fix:** Aggiungere una funzione di utilità condivisa o duplicare il metodo:
```dart
String _fmtDate(String? iso) {
  if (iso == null) return '';
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  } catch (_) { return iso; }
}

// Poi:
Text('${_fmtDate(review.startDate)} → ${_fmtDate(review.endDate)}')
```

---

## 🔵 I-2 — Singleton `DbHelper` non thread-safe su web

**File:** `src/lib/database/db_helper.dart`

**Problema:**  
```dart
Future<Database> get database async {
  _db ??= await _initDb();   // ← non atomico
  return _db!;
}
```

Su Flutter Web con chiamate concorrenti (es. caricamento dashboard + sync cloud contemporanei), il check `_db ??= await _initDb()` può essere eseguito due volte prima che il primo `await` completi, inizializzando due istanze di database.

**Fix:**
```dart
Future<Database>? _initFuture;

Future<Database> get database async {
  _initFuture ??= _initDb();
  return _initFuture!;
}
```

In questo modo anche con chiamate concorrenti viene eseguita una sola inizializzazione.

---

## NOTE GENERALI

Il codebase è di **buona qualità** per un progetto Flutter personale. L'architettura è pulita, la gestione degli errori è presente ovunque con try/catch, le RLS Supabase sono configurate correttamente, il DB locale con migrazioni è gestito bene fino alla versione 5.

Il punto più urgente da fixare è **C-1** (rotazione delle chiavi Supabase) e **M-3** (trigger profilo mancante nello schema SQL) prima di altri utenti che si registrano.

---

*Report generato il 2026-03-10 — Voli di Carta v1.3.15 — Round 1*
