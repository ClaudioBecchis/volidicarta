$flutter = "C:\Users\Black\flutter\bin\flutter.bat"
$ScriptDir = "C:\Users\Black\BookReview"
$SrcDir = "$ScriptDir\src"
$ProjectDir = "$ScriptDir\book_review"
$OutputDir = "$ScriptDir\output"

$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:ANDROID_HOME = "C:\Android\android-sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\android-sdk"
$env:Path = "$env:Path;C:\Users\Black\flutter\bin"

Write-Host "=== BookShelf Build Finale ===" -ForegroundColor Cyan

# 1. Crea progetto Flutter
Write-Host "[1/5] Creazione progetto..." -ForegroundColor Yellow
Set-Location $ScriptDir
if (Test-Path $ProjectDir) { Remove-Item $ProjectDir -Recurse -Force }
& $flutter create book_review --platforms=windows,android --org=it.polariscore 2>&1 | Where-Object { $_ -notmatch "^Resolving|^Downloading|^Got dep" }
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE flutter create" -ForegroundColor Red; exit 1 }

# 2. Copia sorgenti
Write-Host "[2/5] Copia sorgenti..." -ForegroundColor Yellow
Copy-Item "$SrcDir\pubspec.yaml" "$ProjectDir\pubspec.yaml" -Force
Remove-Item "$ProjectDir\lib" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$SrcDir\lib" "$ProjectDir\" -Recurse -Force

# 3. pub get
Write-Host "[3/5] flutter pub get..." -ForegroundColor Yellow
Set-Location $ProjectDir
& $flutter pub get 2>&1 | Where-Object { $_ -match "^(Changed|Got|Error|Err)" }
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE pub get" -ForegroundColor Red; exit 1 }

# 4. Build Windows EXE
Write-Host "[4/5] Build Windows EXE (release)..." -ForegroundColor Yellow
& $flutter build windows --release 2>&1
$winOk = $LASTEXITCODE -eq 0

# 5. Build Android APK
Write-Host "[5/5] Build Android APK (release)..." -ForegroundColor Yellow
& $flutter build apk --release 2>&1
$apkOk = $LASTEXITCODE -eq 0

# Copia output
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

if ($winOk) {
    $winSrc = "$ProjectDir\build\windows\x64\runner\Release"
    $winDest = "$OutputDir\BookShelf-Windows"
    if (Test-Path $winDest) { Remove-Item $winDest -Recurse -Force }
    Copy-Item $winSrc $winDest -Recurse
    Write-Host ""
    Write-Host "EXE PRONTO: $winDest\book_review.exe" -ForegroundColor Green
    Start-Process "$winDest\book_review.exe"
} else {
    Write-Host "Build Windows FALLITA" -ForegroundColor Red
}

if ($apkOk) {
    $apkSrc = "$ProjectDir\build\app\outputs\flutter-apk\app-release.apk"
    $apkDest = "$OutputDir\BookShelf.apk"
    Copy-Item $apkSrc $apkDest -Force
    Write-Host "APK PRONTO: $apkDest" -ForegroundColor Green
} else {
    Write-Host "Build APK FALLITA (controlla Android SDK)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== COMPLETATO ===" -ForegroundColor Cyan
