# BookShelf - Script di Setup Automatico
# Eseguire come Amministratore in PowerShell

param(
    [switch]$BuildWindows,
    [switch]$BuildAndroid,
    [switch]$BuildAll
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Join-Path $ScriptDir "src"
$ProjectDir = Join-Path $ScriptDir "book_review"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BookShelf - Setup App Recensioni" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ----- 1. Verifica Flutter -----
Write-Host "[1/5] Verifica Flutter..." -ForegroundColor Yellow
$flutter = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutter) {
    Write-Host ""
    Write-Host "Flutter non trovato. Installazione..." -ForegroundColor Red
    Write-Host ""
    Write-Host "Passi manuali richiesti:" -ForegroundColor White
    Write-Host "  1. Scarica Flutter da: https://docs.flutter.dev/get-started/install/windows/desktop" -ForegroundColor White
    Write-Host "  2. Estrai in C:\flutter" -ForegroundColor White
    Write-Host "  3. Aggiungi C:\flutter\bin al PATH" -ForegroundColor White
    Write-Host "  4. Esegui: flutter doctor" -ForegroundColor White
    Write-Host "  5. Esegui di nuovo questo script" -ForegroundColor White
    Write-Host ""
    Write-Host "Oppure installa tramite winget:" -ForegroundColor Cyan
    Write-Host "  winget install Google.Flutter" -ForegroundColor Cyan
    Write-Host ""

    $choice = Read-Host "Vuoi installare Flutter tramite winget ora? (S/N)"
    if ($choice -eq "S" -or $choice -eq "s") {
        Write-Host "Installazione Flutter tramite winget..." -ForegroundColor Yellow
        winget install Google.Flutter --accept-source-agreements --accept-package-agreements
        # Ricarica PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $flutter = Get-Command flutter -ErrorAction SilentlyContinue
        if (-not $flutter) {
            Write-Host "Riavvia PowerShell e riesegui lo script." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Installa Flutter manualmente e riesegui lo script." -ForegroundColor Red
        exit 1
    }
}

Write-Host "  Flutter trovato: $(flutter --version | Select-Object -First 1)" -ForegroundColor Green

# ----- 2. Crea progetto Flutter -----
Write-Host ""
Write-Host "[2/5] Creazione progetto Flutter..." -ForegroundColor Yellow

if (Test-Path $ProjectDir) {
    Write-Host "  Progetto esistente trovato, aggiornamento sorgenti..." -ForegroundColor Cyan
} else {
    Set-Location $ScriptDir
    flutter create book_review --platforms=windows,android --org=it.polariscore
    if ($LASTEXITCODE -ne 0) { Write-Host "Errore nella creazione del progetto!" -ForegroundColor Red; exit 1 }
}

# ----- 3. Copia sorgenti -----
Write-Host ""
Write-Host "[3/5] Copia sorgenti personalizzati..." -ForegroundColor Yellow

# Copia pubspec.yaml
Copy-Item -Path (Join-Path $SrcDir "pubspec.yaml") -Destination $ProjectDir -Force

# Copia lib/
$libDest = Join-Path $ProjectDir "lib"
if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
Copy-Item -Path (Join-Path $SrcDir "lib") -Destination $ProjectDir -Recurse -Force

Write-Host "  Sorgenti copiati." -ForegroundColor Green

# ----- 4. Installa dipendenze -----
Write-Host ""
Write-Host "[4/5] Installazione dipendenze..." -ForegroundColor Yellow
Set-Location $ProjectDir
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Host "Errore: flutter pub get fallito!" -ForegroundColor Red; exit 1 }

# Fix Android SDK se necessario
flutter doctor --android-licenses 2>$null | Out-Null

Write-Host "  Dipendenze installate." -ForegroundColor Green

# ----- 5. Build -----
Write-Host ""
Write-Host "[5/5] Compilazione..." -ForegroundColor Yellow

$doBuildWindows = $BuildWindows -or $BuildAll -or (-not $BuildAndroid)
$doBuildAndroid = $BuildAndroid -or $BuildAll

if (-not $BuildWindows -and -not $BuildAndroid -and -not $BuildAll) {
    Write-Host ""
    Write-Host "Cosa vuoi compilare?" -ForegroundColor Cyan
    Write-Host "  [1] Solo Windows (EXE)" -ForegroundColor White
    Write-Host "  [2] Solo Android (APK)" -ForegroundColor White
    Write-Host "  [3] Entrambi" -ForegroundColor White
    $choice = Read-Host "Scelta (1/2/3)"
    switch ($choice) {
        "1" { $doBuildWindows = $true; $doBuildAndroid = $false }
        "2" { $doBuildWindows = $false; $doBuildAndroid = $true }
        "3" { $doBuildWindows = $true; $doBuildAndroid = $true }
        default { $doBuildWindows = $true; $doBuildAndroid = $false }
    }
}

$OutputDir = Join-Path $ScriptDir "output"
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

# Build Windows
if ($doBuildWindows) {
    Write-Host ""
    Write-Host "  Compilazione Windows..." -ForegroundColor Cyan
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Errore build Windows!" -ForegroundColor Red
    } else {
        $winBuild = Join-Path $ProjectDir "build\windows\x64\runner\Release"
        $winDest = Join-Path $OutputDir "BookShelf-Windows"
        if (Test-Path $winDest) { Remove-Item $winDest -Recurse -Force }
        Copy-Item -Path $winBuild -Destination $winDest -Recurse
        Write-Host ""
        Write-Host "  BUILD WINDOWS COMPLETATO!" -ForegroundColor Green
        Write-Host "  Cartella: $winDest" -ForegroundColor Green
        Write-Host "  EXE: $winDest\book_review.exe" -ForegroundColor Green
    }
}

# Build Android
if ($doBuildAndroid) {
    Write-Host ""
    Write-Host "  Compilazione Android APK..." -ForegroundColor Cyan

    # Verifica Java/Android SDK
    $java = Get-Command java -ErrorAction SilentlyContinue
    if (-not $java) {
        Write-Host "  ATTENZIONE: Java non trovato. Per compilare APK serve:" -ForegroundColor Yellow
        Write-Host "    - Android Studio: https://developer.android.com/studio" -ForegroundColor White
        Write-Host "    - Java JDK 17+" -ForegroundColor White
        Write-Host "    - Android SDK (installato con Android Studio)" -ForegroundColor White
        Write-Host "  Esegui 'flutter doctor' per i dettagli." -ForegroundColor Yellow
    } else {
        flutter build apk --release
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Errore build APK! Esegui 'flutter doctor' per diagnosticare." -ForegroundColor Red
        } else {
            $apkSrc = Join-Path $ProjectDir "build\app\outputs\flutter-apk\app-release.apk"
            $apkDest = Join-Path $OutputDir "BookShelf.apk"
            Copy-Item -Path $apkSrc -Destination $apkDest -Force
            Write-Host ""
            Write-Host "  BUILD ANDROID COMPLETATO!" -ForegroundColor Green
            Write-Host "  APK: $apkDest" -ForegroundColor Green
            Write-Host "  Installa sul dispositivo: adb install $apkDest" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup completato!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($doBuildWindows) {
    $winDest = Join-Path $OutputDir "BookShelf-Windows"
    Write-Host "  Windows EXE: $winDest\book_review.exe" -ForegroundColor White
}
if ($doBuildAndroid) {
    $apkDest = Join-Path $OutputDir "BookShelf.apk"
    Write-Host "  Android APK: $apkDest" -ForegroundColor White
}
Write-Host ""
