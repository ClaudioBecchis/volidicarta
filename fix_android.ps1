$sdkRoot = "C:\Android\android-sdk"
$cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"
$zip = "$env:TEMP\cmdline-tools.zip"
$dest = "$sdkRoot\cmdline-tools"

Write-Host "Fix Android SDK cmdline-tools..." -ForegroundColor Cyan

if (-not (Test-Path "$dest\latest\bin\sdkmanager.bat")) {
    Write-Host "Download cmdline-tools..." -ForegroundColor Yellow
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $cmdlineToolsUrl -Destination $zip

    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Expand-Archive -Path $zip -DestinationPath $dest -Force
    Remove-Item $zip -Force

    # Rinomina la cartella in "latest"
    $extracted = Get-ChildItem $dest -Directory | Select-Object -First 1
    if ($extracted -and $extracted.Name -ne "latest") {
        Rename-Item $extracted.FullName "latest"
    }
}

$sdkmanager = "$dest\latest\bin\sdkmanager.bat"
Write-Host "sdkmanager: $sdkmanager" -ForegroundColor Gray

# Accetta licenze
Write-Host "Accettazione licenze Android..." -ForegroundColor Yellow
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot

for ($i = 0; $i -lt 20; $i++) { "y" } | & $sdkmanager --licenses

# Installa build-tools e platform
Write-Host "Installazione build-tools..." -ForegroundColor Yellow
& $sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

Write-Host "Android SDK pronto!" -ForegroundColor Green
