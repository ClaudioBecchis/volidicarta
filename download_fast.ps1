$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.41.4-stable.zip"
$zip = "$env:USERPROFILE\Downloads\flutter_sdk.zip"

Write-Host "Download Flutter con BITS Transfer (veloce)..." -ForegroundColor Cyan

# Rimuovi download precedente
Remove-Item $zip -Force -ErrorAction SilentlyContinue

# Start-BitsTransfer e' il piu veloce per file grandi in Windows
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $zip -DisplayName "Flutter SDK" -Description "Flutter 3.41.4"

if (Test-Path $zip) {
    $size = [math]::Round((Get-Item $zip).Length / 1MB, 0)
    Write-Host "Download completato: $size MB" -ForegroundColor Green

    Write-Host "Estrazione in $env:USERPROFILE\flutter ..." -ForegroundColor Cyan
    if (Test-Path "$env:USERPROFILE\flutter") {
        Remove-Item "$env:USERPROFILE\flutter" -Recurse -Force
    }
    Expand-Archive -Path $zip -DestinationPath $env:USERPROFILE -Force
    Remove-Item $zip -Force

    # Aggiorna PATH
    $flutterBin = "$env:USERPROFILE\flutter\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*flutter\bin*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
    }
    $env:Path = "$env:Path;$flutterBin"

    Write-Host "Verifica Flutter:" -ForegroundColor Cyan
    & "$flutterBin\flutter.bat" --version
    Write-Host ""
    Write-Host "PRONTO! Flutter installato in $env:USERPROFILE\flutter" -ForegroundColor Green
} else {
    Write-Host "Download fallito!" -ForegroundColor Red
    exit 1
}
