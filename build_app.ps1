$flutter = "$env:USERPROFILE\flutter\bin\flutter.bat"
$ScriptDir = "C:\Users\Black\BookReview"
$SrcDir = "$ScriptDir\src"
$ProjectDir = "$ScriptDir\book_review"
$OutputDir = "$ScriptDir\output"

Write-Host "=== BookShelf Build ===" -ForegroundColor Cyan

# 1. Crea progetto
Write-Host "[1/4] Creazione progetto Flutter..." -ForegroundColor Yellow
Set-Location $ScriptDir
if (Test-Path $ProjectDir) { Remove-Item $ProjectDir -Recurse -Force }
& $flutter create book_review --platforms=windows,android --org=it.polariscore 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE flutter create" -ForegroundColor Red; exit 1 }

# 2. Copia sorgenti
Write-Host "[2/4] Copia sorgenti..." -ForegroundColor Yellow
Copy-Item "$SrcDir\pubspec.yaml" "$ProjectDir\pubspec.yaml" -Force
$libDest = "$ProjectDir\lib"
Remove-Item $libDest -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$SrcDir\lib" "$ProjectDir\" -Recurse -Force
Write-Host "  Sorgenti copiati." -ForegroundColor Green

# 3. pub get
Write-Host "[3/4] flutter pub get..." -ForegroundColor Yellow
Set-Location $ProjectDir
& $flutter pub get 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE pub get" -ForegroundColor Red; exit 1 }

# 4. Build Windows
Write-Host "[4/4] Build Windows EXE..." -ForegroundColor Yellow
& $flutter build windows --release 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE build windows" -ForegroundColor Red; exit 1 }

# Copia output
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$winBuild = "$ProjectDir\build\windows\x64\runner\Release"
$winDest = "$OutputDir\BookShelf-Windows"
if (Test-Path $winDest) { Remove-Item $winDest -Recurse -Force }
Copy-Item $winBuild $winDest -Recurse

Write-Host ""
Write-Host "=== BUILD COMPLETATO! ===" -ForegroundColor Green
Write-Host "EXE: $winDest\book_review.exe" -ForegroundColor White
Write-Host ""
Write-Host "Avvio diretto dell'app..." -ForegroundColor Cyan
Start-Process "$winDest\book_review.exe"
