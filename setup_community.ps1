# BookShelf - Setup Community Supabase
# Esegui questo script DOPO aver configurato supabase_config.dart

$env:VSINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:ANDROID_HOME = "C:\Android\android-sdk"
$FlutterBin = "$env:USERPROFILE\flutter\bin"
$env:PATH = "$FlutterBin;$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"

Set-Location "$env:USERPROFILE\BookReview\src"

Write-Host "=== Aggiornamento dipendenze (supabase_flutter) ===" -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "=== Compilazione EXE Windows ===" -ForegroundColor Cyan
flutter build windows --release

if ($LASTEXITCODE -eq 0) {
    $exeDir = "build\windows\x64\runner\Release"
    Write-Host ""
    Write-Host "BUILD OK! EXE in: $exeDir" -ForegroundColor Green
    Write-Host "Avvio app..." -ForegroundColor Yellow
    Start-Process "$exeDir\book_review.exe"
} else {
    Write-Host "Build fallita." -ForegroundColor Red
}
