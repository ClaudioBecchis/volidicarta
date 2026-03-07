$sdkRoot = "C:\Android\android-sdk"
$cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"
$zip = "$env:TEMP\cmdline-tools.zip"
$dest = "$sdkRoot\cmdline-tools"

Write-Host "Installazione Android cmdline-tools..." -ForegroundColor Cyan

New-Item -ItemType Directory -Path $dest -Force | Out-Null

Write-Host "Download cmdline-tools..." -ForegroundColor Yellow
Import-Module BitsTransfer
Start-BitsTransfer -Source $cmdlineToolsUrl -Destination $zip -DisplayName "Android cmdline-tools"

Write-Host "Estrazione..." -ForegroundColor Yellow
$tmpDir = "$env:TEMP\cmdline-tools-extract"
Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive -Path $zip -DestinationPath $tmpDir -Force
Remove-Item $zip -Force

# La struttura estratta e' cmdline-tools/bin - deve andare in cmdline-tools/latest/
$latestDest = "$dest\latest"
Remove-Item $latestDest -Recurse -Force -ErrorAction SilentlyContinue

$extracted = Get-ChildItem $tmpDir -Directory | Select-Object -First 1
if ($extracted) {
    Copy-Item $extracted.FullName $latestDest -Recurse
} else {
    Copy-Item $tmpDir $latestDest -Recurse
}
Remove-Item $tmpDir -Recurse -Force

$sdkmanager = "$latestDest\bin\sdkmanager.bat"
Write-Host "sdkmanager: $sdkmanager" -ForegroundColor Gray

if (Test-Path $sdkmanager) {
    $env:ANDROID_HOME = $sdkRoot
    $env:ANDROID_SDK_ROOT = $sdkRoot

    Write-Host "Accettazione licenze..." -ForegroundColor Yellow
    "y`ny`ny`ny`ny`ny`ny`ny`ny`ny`n" | & $sdkmanager --sdk_root=$sdkRoot --licenses

    Write-Host "Android SDK pronto!" -ForegroundColor Green
} else {
    Write-Host "sdkmanager non trovato in $sdkmanager" -ForegroundColor Red
    Get-ChildItem $dest -Recurse | Select-Object FullName
}
