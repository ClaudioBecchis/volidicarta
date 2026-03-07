$javaHome = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$sdkRoot = "C:\Android\android-sdk"

Write-Host "Fix JAVA_HOME → $javaHome" -ForegroundColor Cyan

# Imposta JAVA_HOME per l'utente corrente
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "User")
$env:JAVA_HOME = $javaHome
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot

# Verifica Java
& "$javaHome\bin\java.exe" -version

# Accetta licenze Android SDK
Write-Host "Accettazione licenze Android SDK..." -ForegroundColor Yellow
$sdkmanager = "$sdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"
"y`ny`ny`ny`ny`ny`ny`ny`ny`ny`ny`ny`ny`ny`ny`n" | & $sdkmanager --sdk_root=$sdkRoot --licenses

Write-Host "JAVA_HOME aggiornato e licenze accettate!" -ForegroundColor Green
