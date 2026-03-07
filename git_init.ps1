Set-Location 'C:\Users\Black\BookReview'
git init
git config user.email 'claudio@polariscore.it'
git config user.name 'Claudio Becchis'

# Aggiungi tutti i file (il .gitignore del src escluderà i sensibili)
git add README.md LICENSE supabase_schema.sql bookshelf_setup.iss
git add src/

# Rimuovi esplicitamente i file con credenziali dallo staging
git reset HEAD 'src/android/key.properties' 2>$null
git reset HEAD 'src/lib/config/supabase_config.dart' 2>$null
git reset HEAD 'src/android/app/google-services.json' 2>$null

Write-Host "=== File in staging ===" -ForegroundColor Cyan
git status --short
