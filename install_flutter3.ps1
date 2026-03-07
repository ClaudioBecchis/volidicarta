$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.41.4-stable.zip"
$zip = "$env:USERPROFILE\Downloads\flutter_sdk.zip"
$dest = "$env:USERPROFILE\flutter"

Write-Host "Download Flutter 3.41.4..." -ForegroundColor Cyan
Write-Host "Destinazione ZIP: $zip" -ForegroundColor Gray

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing

if (-not (Test-Path $zip)) {
    Write-Host "Download fallito!" -ForegroundColor Red
    exit 1
}

$size = [math]::Round((Get-Item $zip).Length / 1MB, 0)
Write-Host "Scaricato: $size MB" -ForegroundColor Green

Write-Host "Estrazione in $dest ..." -ForegroundColor Cyan
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
New-Item -ItemType Directory -Path "$env:USERPROFILE" -Force | Out-Null
Expand-Archive -Path $zip -DestinationPath "$env:USERPROFILE" -Force
Remove-Item $zip -Force

Write-Host "Aggiunta al PATH utente..." -ForegroundColor Cyan
$flutterBin = "$dest\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBin", "User")
}
$env:Path = "$env:Path;$flutterBin"

Write-Host "Verifico installazione..." -ForegroundColor Cyan
& "$dest\bin\flutter.bat" --version

Write-Host ""
Write-Host "Flutter installato in: $dest" -ForegroundColor Green
