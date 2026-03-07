$flutter = "C:\Users\Black\flutter\bin\flutter.bat"
$ProjectDir = "C:\Users\Black\BookReview\book_review"
$OutputDir = "C:\Users\Black\BookReview\output"

$env:VSINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:ANDROID_HOME = "C:\Android\android-sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\android-sdk"

Set-Location $ProjectDir

Write-Host "=== Build Android APK ===" -ForegroundColor Cyan
& $flutter build apk --release
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE APK!" -ForegroundColor Red; exit 1 }

$apkSrc  = "$ProjectDir\build\app\outputs\flutter-apk\app-release.apk"
$apkDest = "$OutputDir\BookShelf.apk"
Copy-Item $apkSrc $apkDest -Force

Write-Host ""
Write-Host "APK PRONTO: $apkDest" -ForegroundColor Green
