// Configurazione app — chiave Google Books API
//
// Senza chiave: limite ~100 ricerche/giorno per IP (errore 429)
// Con chiave gratuita: 1000 ricerche/giorno
//
// Per ottenere una chiave gratuita:
// 1. Vai su console.cloud.google.com
// 2. Crea un progetto → API e servizi → Abilita API
// 3. Cerca "Books API" e abilitala
// 4. Credenziali → Crea credenziali → Chiave API
// 5. Incolla la chiave sotto

class AppConfig {
  // Chiave API Google Books (opzionale ma consigliata)
  static const String googleBooksApiKey = '';

  static bool get hasGoogleApiKey =>
      googleBooksApiKey.isNotEmpty && googleBooksApiKey != 'YOUR_API_KEY';
}
