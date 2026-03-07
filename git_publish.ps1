Set-Location 'C:\Users\Black\BookReview'

# Primo commit
git commit -m "Initial release: BookShelf v1.0.0

App Flutter open source per recensire libri.
- Ricerca Google Books API
- Recensioni locali (SQLite)
- Community pubblica (Supabase)
- Autenticazione cloud
- Inizio/fine lettura, tema, lingue"

# Crea il repo pubblico su GitHub
gh repo create bookshelf `
  --public `
  --description "BookShelf - App Flutter open source per recensire libri. Windows + Android." `
  --homepage "https://polariscore.it" `
  --push `
  --source .

Write-Host "`nRepo pubblicato!" -ForegroundColor Green
gh repo view --web
