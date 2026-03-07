$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.41.4-stable.zip"
$zip = "C:\flutter_sdk.zip"

Write-Host "Download Flutter 3.41.4 con curl..." -ForegroundColor Cyan

# Usa curl.exe integrato in Windows 10/11
& curl.exe -L -o $zip --progress-bar $url
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $zip)) {
    Write-Host "curl fallito, provo Invoke-WebRequest..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
}

if (-not (Test-Path $zip)) {
    Write-Host "Download fallito!" -ForegroundColor Red
    exit 1
}

$size = (Get-Item $zip).Length / 1MB
Write-Host "Scaricato: $([math]::Round($size,0)) MB" -ForegroundColor Green

Write-Host "Estrazione in C:\flutter ..." -ForegroundColor Cyan
if (Test-Path "C:\flutter") { Remove-Item "C:\flutter" -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath "C:\" -Force
Remove-Item $zip -Force

Write-Host "Aggiunta al PATH utente..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*C:\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\flutter\bin", "User")
}

Write-Host "Flutter installato in C:\flutter" -ForegroundColor Green
Write-Host "Versione:" -ForegroundColor Cyan
& "C:\flutter\bin\flutter.bat" --version
