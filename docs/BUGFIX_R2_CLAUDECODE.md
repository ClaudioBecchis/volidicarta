# 🔍 Bug Fix Report — Round 2

> **Repository:** volidicarta · Flutter/Dart/Supabase  
> **Versione analizzata:** 1.3.15+28 (master)  
> **Preparato da:** Claude (Anthropic) · Marzo 2026  
> **Scope:** File non analizzati in Round 1 — update_service, crash_service, settings_service, admin_users_screen, forum_screen, stats_screen, search_screen, wishlist_screen, my_reviews_screen, register_screen, db_helper (completo), supabase_schema.sql (completo)

---

## 📋 Sommario Round 2

| ID | Gravità | Descrizione | File |
|----|---------|-------------|------|
| **C-3** | 🔴 Critico | Tabella `user_reviews` usata da `ReviewSyncService` NON ESISTE nello schema Supabase → backup cloud recensioni private completamente non funzionante | `services/review_sync_service.dart` · `supabase_schema.sql` |
| **M-5** | 🟡 Media | Colonna `is_admin` non definita in `profiles` → `AuthService.refreshAdminStatus()` ritorna sempre `false`, sistema admin DB inutilizzabile | `supabase_schema.sql` · `services/auth_service.dart` |
| **M-6** | 🟡 Media | `ReviewSyncService().delete()` non awaited in `_deleteReview()` → cancellazione cloud fire-and-forget, stesso pattern di M-2 | `screens/my_reviews_screen.dart` |
| **M-7** | 🟡 Media | `UpdateService.downloadAndInstall()` non verifica SHA-256 — implementazione parallela a `UpdateDialog._update()` ma senza verifica integrità | `services/update_service.dart` |
| **I-3** | 🔵 Bassa | `getStatsByYear()` raggruppa per `created_at` (data recensione) invece di `end_date` (data lettura) | `database/db_helper.dart` |
| **I-4** | 🔵 Bassa | Privacy policy afferma "NESSUN dato locale" ma l'app salva in SQLite locale → dichiarazione GDPR non accurata | `screens/register_screen.dart` |
| **I-5** | 🔵 Bassa | `WishlistBook` creato senza `bookGenre` in `SearchScreen._toggleWishlist()` | `screens/search_screen.dart` |

---

## 🔴 C-3 — Tabella `user_reviews` inesistente in Supabase

**Impatto:** tutti gli utenti — backup cloud recensioni private completamente non funzionante

### Problema

`ReviewSyncService` fa upsert/delete/select sulla tabella `user_reviews`, che **non è mai stata definita** nello schema Supabase (`supabase_schema.sql`). Lo schema contiene solo `public_reviews` (per il feed community). Gli errori vengono swallowed silenziosamente nel try/catch.

```dart
// review_sync_service.dart
await c.from('user_reviews').upsert({...}, onConflict: 'user_id,book_id'); // ❌ tabella inesistente
await c.from('user_reviews').delete()...;  // ❌
await c.from('user_reviews').select()...;  // ❌
```

**Conseguenze:**
- Il backup automatico al salvataggio non funziona
- `syncFromCloud()` al login non scarica nulla
- `uploadAll()` non ha effetto
- L'utente crede le recensioni siano al sicuro nel cloud ma non lo sono

### Fix

Aggiungere la tabella allo schema:

```sql
create table user_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  book_id text not null,
  book_title text not null,
  book_author text not null,
  book_cover_url text,
  book_publisher text,
  book_year text,
  book_genre text,
  rating int not null check (rating between 1 and 5),
  review_title text,
  review_body text,
  start_date text,
  end_date text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, book_id)
);
alter table user_reviews enable row level security;
create policy "ur_own" on user_reviews using (auth.uid() = user_id);
create policy "ur_insert" on user_reviews for insert with check (auth.uid() = user_id);
```

---

## 🟡 M-5 — Schema mancante: colonna `is_admin` in `profiles`

**Impatto:** sistema di permessi admin non funzionante

### Problema

`AuthService.refreshAdminStatus()` legge `profiles.is_admin`, ma la colonna non è nello schema.  
La query ritorna la riga senza il campo → `_isAdmin = false` sempre.

```dart
// auth_service.dart
final res = await c.from('profiles').select('is_admin').eq('id', uid).maybeSingle();
_isAdmin = (res?['is_admin'] as bool?) ?? false; // sempre false — colonna inesistente
```

### Fix

```sql
alter table profiles add column if not exists is_admin boolean default false;
```

---

## 🟡 M-6 — `ReviewSyncService().delete()` non awaited

**Impatto:** recensioni eliminate localmente potrebbero rientrare dal cloud al prossimo sync

### Problema

Stesso pattern del bug M-2 (Round 1) ma per la cancellazione:

```dart
// screens/my_reviews_screen.dart — _deleteReview()
await DbHelper().deleteReview(r.id!);           // ✅ awaited
ReviewSyncService().delete(r.userId, r.bookId); // ❌ non awaited — fire & forget
```

### Fix

```dart
await ReviewSyncService().delete(r.userId, r.bookId);
```

---

## 🟡 M-7 — `UpdateService.downloadAndInstall()` non verifica SHA-256

**Impatto:** file di aggiornamento corrotti/manomessi vengono installati silenziosamente

### Problema

Esistono due implementazioni parallele del download aggiornamenti:

- **`UpdateDialog._update()`** → verifica SHA-256 su Windows con `package:crypto` ✅  
- **`UpdateService.downloadAndInstall()`** → scarica e installa senza nessuna verifica ❌

Il campo `UpdateInfo.sha256` viene ricevuto dal server ma mai usato in `UpdateService`.  
Su Android la verifica è assente anche in `UpdateDialog`.

```dart
// update_service.dart — downloadAndInstall()
await exeFile.writeAsBytes(await response.stream.toBytes());
await Process.start(exeFile.path, ['/S']); // installa senza verificare sha256
```

### Fix

Eliminare `UpdateService.downloadAndInstall()` e centralizzare la logica in `UpdateDialog`,  
oppure portare la verifica SHA-256 (per entrambe le piattaforme) anche in `UpdateService`.

---

## 🔵 I-3 — `getStatsByYear()` usa `created_at` invece di `end_date`

**Impatto:** UX — statistiche "Libri per anno" fuorvianti

### Problema

```dart
// db_helper.dart — getStatsByYear()
'''SELECT SUBSTR(created_at, 1, 4) as yr ...'''  // usa data inserimento recensione
```

Se l'utente aggiunge in blocco libri letti in anni precedenti, appaiono tutti nell'anno corrente.

### Fix

```sql
SELECT SUBSTR(COALESCE(NULLIF(end_date,''), created_at), 1, 4) as yr
```

---

## 🔵 I-4 — Privacy policy non accurata (problema GDPR)

**Impatto:** compliance GDPR — dichiarazione falsa

### Problema

Il testo in `RegisterScreen` afferma:
> *"NESSUN dato viene conservato localmente sul dispositivo in uso"*

L'app salva un database SQLite locale (`volidicarta.db`) con **tutte le recensioni e la wishlist**.

### Fix

Aggiornare il testo in `register_screen.dart`:
> "I tuoi dati vengono salvati sui server Supabase (EU) **e memorizzati localmente sul dispositivo per il funzionamento offline**."

---

## 🔵 I-5 — `WishlistBook` senza `bookGenre` in `SearchScreen`

**Impatto:** UX — libri dalla ricerca senza genere nella wishlist

### Problema

```dart
// screens/search_screen.dart — _toggleWishlist()
final wb = WishlistBook(
  userId: uid,
  bookId: book.id,
  bookTitle: book.title,
  bookAuthor: book.authors,
  bookCoverUrl: book.coverUrl,
  bookPublisher: book.publisher,
  bookYear: ...,
  addedAt: DateTime.now().toIso8601String(),
  // bookGenre: mancante — book.categories disponibile ma non passato
);
```

### Fix

```dart
bookGenre: book.categories, // aggiungere
```

---

## 📊 Riepilogo Totale (Round 1 + Round 2)

| ID | Gravità | Stato |
|----|---------|-------|
| C-1 | 🔴 Critico | Chiavi Supabase hardcoded → PENDING |
| C-2 | 🔴 Critico | Doppio sistema auth → PENDING |
| C-3 | 🔴 Critico | Tabella user_reviews inesistente → ✅ FIXED (schema aggiornato) |
| M-1 | 🟡 Media | get_community_stats() campi mancanti → PENDING |
| M-2 | 🟡 Media | upsert() non awaited → PENDING |
| M-3 | 🟡 Media | profiles non creato alla registrazione → PENDING |
| M-4 | 🟡 Media | Admin hardcoded su 'claudio' → PENDING |
| M-5 | 🟡 Media | Schema: is_admin mancante → ✅ FIXED (schema aggiornato) |
| M-6 | 🟡 Media | delete() non awaited → ✅ FIXED (await aggiunto) |
| M-7 | 🟡 Media | SHA-256 non verificato in UpdateService → ✅ FIXED (verifica aggiunta) |
| I-1 | 🔵 Bassa | Date formato ISO raw → PENDING |
| I-2 | 🔵 Bassa | DbHelper non thread-safe web → PENDING |
| I-3 | 🔵 Bassa | Stats anno usa created_at → ✅ FIXED (COALESCE end_date) |
| I-4 | 🔵 Bassa | Privacy policy errata → ✅ FIXED (testo aggiornato) |
| I-5 | 🔵 Bassa | WishlistBook senza bookGenre → ✅ FIXED (book.categories passato) |

**Totale: 3 Critici · 7 Medi · 5 Bassi · 7 nuovi in Round 2 · 7 già risolti · 1 fixato ora (M-7)**

---

*Claude (Anthropic) · Analisi statica manuale · Marzo 2026*
