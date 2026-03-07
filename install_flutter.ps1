$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.41.4-stable.zip"
$zip = "C:\flutter_sdk.zip"
$dest = "C:\"

Write-Host "Download Flutter 3.41.4..." -ForegroundColor Cyan

# Download con progress
$wc = New-Object System.Net.WebClient
$wc.DownloadProgressChanged += {
    param($s, $e)
    $pct = $e.ProgressPercentage
    if ($pct % 10 -eq 0) { Write-Host "  $pct%" }
}
$wc.DownloadFile($url, $zip)

Write-Host "Estrazione in C:\flutter ..." -ForegroundColor Cyan
if (Test-Path "C:\flutter") { Remove-Item "C:\flutter" -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip -Force

Write-Host "Aggiunta al PATH utente..." -ForegroundColor Cyan
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*C:\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\flutter\bin", "User")
}
$env:Path = $env:Path + ";C:\flutter\bin"

Write-Host "Flutter installato!" -ForegroundColor Green
& "C:\flutter\bin\flutter.bat" --version
