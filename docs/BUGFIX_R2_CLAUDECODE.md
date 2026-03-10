# Bug Analysis Round 2 — Voli di Carta

> **Analisi:** Claude Sonnet 4.6 · **Data:** 2026-03-10  
> **Versione analizzata:** 1.3.17+28 (master)  
> **Round precedente:** [BUGFIX_R1_CLAUDECODE.md](./BUGFIX_R1_CLAUDECODE.md) — 8 bug trovati, tutti corretti in v1.3.16

---

## Riepilogo Round 2

| ID   | Gravità       | File                                    | Descrizione sintetica                              | Status  |
|------|---------------|-----------------------------------------|----------------------------------------------------|---------|
| N-1  | 🔴 Critico    | `about_screen.dart`                     | Controller disposed prima di leggere `.text` → bug report/suggerimento sempre vuoto | PENDING |
| N-2  | 🟡 Media      | `my_reviews_screen.dart`                | `ReviewSyncService().delete()` non awaited → errori cloud silenziosi | PENDING |
| N-3  | 🟡 Media      | `community_review_detail_screen.dart`   | `SupabaseService().currentUser` per auth check — inconsistente con `AuthService()` | PENDING |
| N-4  | 🟡 Media      | `settings_screen.dart`                  | Versione hardcoded `v1.0.7` nel footer (attuale: 1.3.17) | PENDING |
| N-5  | 🔵 Bassa      | `forum_thread_detail_screen.dart`       | Nessun `if (mounted)` dopo `Future.delayed` prima di `_scrollCtrl.animateTo()` | PENDING |
| N-6  | 🔵 Bassa      | `splash_screen.dart`                    | Metodo statico `_isAndroidPlatform` definito ma mai usato (dead code) | PENDING |
| N-7  | 🔵 Bassa      | `update_service.dart` vs `update_dialog.dart` | Nome file APK inconsistente nei due componenti di update | PENDING |

---

## Dettaglio Bug

---

### N-1 🔴 — `about_screen.dart`: Controller disposed prima di leggere `.text`

**File:** `src/lib/screens/about_screen.dart`  
**Metodi:** `_suggestImprovement()`, `_reportBug()`

**Problema:** In entrambi i metodi, i `TextEditingController` vengono disposti (`dispose()`) **prima** di leggere il loro contenuto. Il risultato è che il testo digitato dall'utente viene perso: la segnalazione/suggerimento viene inviata vuota anche se l'utente aveva scritto qualcosa.

**Codice difettoso — `_suggestImprovement()`:**
```dart
final result = await showDialog<bool>(...);  // l'utente digita nel dialog
titleCtrl.dispose();   // ← dispose PRIMA di leggere
bodyCtrl.dispose();    // ← dispose PRIMA di leggere
if (result != true || !mounted) return;
final t = titleCtrl.text.trim();  // ← legge da controller già disposed → ""
final b = bodyCtrl.text.trim();   // ← legge da controller già disposed → ""
if (t.isEmpty) return;            // ← esce sempre, issue mai inviata!
```

**Codice difettoso — `_reportBug()`:**
```dart
final result = await showDialog<bool>(...);
descCtrl.dispose();                   // ← dispose PRIMA di leggere
if (result != true || !mounted) return;
final desc = descCtrl.text.trim();    // ← legge da controller già disposed → ""
```

**Fix:**
```dart
// _suggestImprovement()
final result = await showDialog<bool>(...);
// Leggi il testo PRIMA di dispose
final t = titleCtrl.text.trim();
final b = bodyCtrl.text.trim();
titleCtrl.dispose();
bodyCtrl.dispose();
if (result != true || !mounted) return;
if (t.isEmpty) return;
// ... resto invariato

// _reportBug()
final result = await showDialog<bool>(...);
final desc = descCtrl.text.trim();  // leggi prima
descCtrl.dispose();
if (result != true || !mounted) return;
// ... resto invariato
```

**Impatto:** Critico — bug report e suggerimenti vengono sempre inviati vuoti a GitHub, rendendo la funzionalità completamente inutile.

---

### N-2 🟡 — `my_reviews_screen.dart`: `ReviewSyncService().delete()` non awaited

**File:** `src/lib/screens/my_reviews_screen.dart`  
**Metodo:** `_deleteReview()`

**Problema:** La cancellazione cloud non è awaited, analoga al bug M-2 già corretto per l'upsert. Gli errori di rete durante la cancellazione vengono ignorati silenziosamente.

**Codice difettoso:**
```dart
try {
  await DbHelper().deleteReview(r.id!);
  ReviewSyncService().delete(r.userId, r.bookId);  // ← non awaited
  _load();
}
```

**Fix:**
```dart
try {
  await DbHelper().deleteReview(r.id!);
  try {
    await ReviewSyncService().delete(r.userId, r.bookId);
  } catch (e) {
    debugPrint('Cloud delete sync error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recensione eliminata localmente. Sync cloud non riuscita.')),
      );
    }
  }
  _load();
}
```

**Impatto:** La recensione viene eliminata localmente ma rimane su Supabase se la rete fallisce. Al prossimo sync cloud potrebbe riapparire.

---

### N-3 🟡 — `community_review_detail_screen.dart`: Auth check via `SupabaseService` invece di `AuthService`

**File:** `src/lib/screens/community_review_detail_screen.dart`  
**Riga:** `final isMyReview = SupabaseService().currentUser?.id == _review.userId;`

**Problema:** Il check di ownership usa `SupabaseService().currentUser` invece di `AuthService().currentUser`. Dopo la correzione C-2 di Round 1 (che ha unificato l'auth su `AuthService`), questo è l'ultimo punto nell'app che bypassa `AuthService`. Se le due sorgenti restituiscono utenti diversi (es. durante refresh di sessione), il pulsante "Elimina" potrebbe apparire o sparire erroneamente.

**Fix:**
```dart
// Prima
import '../services/supabase_service.dart';
final isMyReview = SupabaseService().currentUser?.id == _review.userId;

// Dopo
import '../services/auth_service.dart';
final isMyReview = AuthService().currentUser?.id == _review.userId;
```

**Impatto:** Incoerenza architetturale che può causare bug sottili durante il refresh della sessione.

---

### N-4 🟡 — `settings_screen.dart`: Versione hardcoded nel footer

**File:** `src/lib/screens/settings_screen.dart`

**Problema:** Il footer della schermata Impostazioni mostra la versione hardcoded `v1.0.7`, mentre la versione attuale è `1.3.17`. Il bug esiste da molto tempo (la schermata non è mai stata aggiornata) e crea confusione all'utente che si trova la versione corretta su "Info App" ma quella vecchia su "Impostazioni".

**Codice difettoso:**
```dart
Center(
  child: Text(
    'Voli di Carta v1.0.7\nClaudio Becchis · polariscore.it',
    // ...
  ),
),
```

**Fix:** Convertire `_SettingsScreenState` per caricare la versione dinamicamente (come già fatto in `AboutScreen`), oppure rimuovere semplicemente la riga della versione dal footer di Impostazioni, lasciandola solo in "Info App".

```dart
// Soluzione semplice: rimuovi la versione dal footer di Settings
Center(
  child: Text(
    'Claudio Becchis · polariscore.it',
    // ...
  ),
),
```

**Impatto:** Informazione errata mostrata all'utente. Versione "Info App" = corretta, versione "Impostazioni" = obsoleta (v1.0.7).

---

### N-5 🔵 — `forum_thread_detail_screen.dart`: Missing `mounted` check dopo `Future.delayed`

**File:** `src/lib/screens/forum_thread_detail_screen.dart`  
**Metodo:** `_sendReply()`

**Problema:** Dopo aver inviato una risposta, c'è un `Future.delayed(100ms)` per aspettare il rebuild prima di scrollare in fondo. Non c'è un controllo `if (mounted)` prima di chiamare `_scrollCtrl.animateTo(...)`. Se l'utente naviga indietro durante i 100ms, lo `ScrollController` non è più attaccato a nessuna view e viene lanciato un `StateError`.

**Codice difettoso:**
```dart
await Future.delayed(const Duration(milliseconds: 100));
_scrollCtrl.animateTo(          // ← nessun mounted check
  _scrollCtrl.position.maxScrollExtent,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

**Fix:**
```dart
await Future.delayed(const Duration(milliseconds: 100));
if (!mounted) return;           // ← aggiungere questo check
_scrollCtrl.animateTo(
  _scrollCtrl.position.maxScrollExtent,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

---

### N-6 🔵 — `splash_screen.dart`: Metodo `_isAndroidPlatform` mai usato

**File:** `src/lib/screens/splash_screen.dart`

**Problema:** Il metodo statico `_isAndroidPlatform` è definito nella classe ma non viene mai chiamato da nessuna parte. È dead code rimasto da una refactoring precedente.

**Codice da rimuovere:**
```dart
static bool _isAndroidPlatform(TargetPlatform p) => p == TargetPlatform.android;
```

La logica Android è già inline nel codice (`defaultTargetPlatform == TargetPlatform.android`) ed `UpdateService` espone `UpdateService.isAndroid` per uso esterno.

---

### N-7 🔵 — `update_service.dart` vs `update_dialog.dart`: Nome file APK inconsistente

**File:** `src/lib/services/update_service.dart`, `src/lib/widgets/update_dialog.dart`

**Problema:** I due componenti usano nomi diversi per il file APK temporaneo:
- `update_service.dart` (metodo `downloadAndInstall`): `VDC_update_${version}.apk`
- `update_dialog.dart` (classe `UpdateDialog`): `VoliDiCarta_v${version}.apk`

Se entrambi i path vengono eseguiti nella stessa sessione (es. aggiornamento automatico in background + utente preme manualmente "Installa"), vengono creati due file APK duplicati nella cartella temporanea.

**Fix:** Centralizzare il nome del file in `UpdateService`:
```dart
// In UpdateService
static String apkFileName(String version) => 'VoliDiCarta_v$version.apk';
static String exeFileName(String version) => 'VoliDiCarta_v${version}_Setup.exe';
```
E usare questi metodi in entrambi i file.

---

## Note aggiuntive

### C-1 ancora aperta
Le credenziali Supabase (`anonKey`, `anonJwt`) in `supabase_config.dart` sono ancora hardcoded nel repository pubblico. Questo era il bug più critico di Round 1 e rimane irrisolto. Si raccomanda di ruotare immediatamente le chiavi dal pannello Supabase e migrare a una soluzione con variabili d'ambiente o file di configurazione gitignored.

### Fallback versione hardcoded in `about_screen.dart`
Il fallback `_currentVersion = '1.3.12'` nel catch di `PackageInfo.fromPlatform()` è già obsoleto (versione attuale: 1.3.17). Se `PackageInfo` fallisce, l'utente vede una versione sbagliata. Considerare di usare la stringa `'sconosciuta'` come fallback.

---

*Generato da Claude Sonnet 4.6 — volidicarta Round 2*
