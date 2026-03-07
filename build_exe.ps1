$flutter = "C:\Users\Black\flutter\bin\flutter.bat"
$ProjectDir = "C:\Users\Black\BookReview\book_review"
$OutputDir = "C:\Users\Black\BookReview\output"

# Forza Flutter a usare Build Tools 2022 (che ha MSVC v143) invece di VS 2026
$env:VSINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:ANDROID_HOME = "C:\Android\android-sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\android-sdk"

Set-Location $ProjectDir

Write-Host "=== Build Windows EXE ===" -ForegroundColor Cyan
& $flutter build windows --release
if ($LASTEXITCODE -ne 0) { Write-Host "ERRORE!" -ForegroundColor Red; exit 1 }

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$winSrc  = "$ProjectDir\build\windows\x64\runner\Release"
$winDest = "$OutputDir\BookShelf-Windows"
if (Test-Path $winDest) { Remove-Item $winDest -Recurse -Force }
Copy-Item $winSrc $winDest -Recurse

Write-Host ""
Write-Host "EXE PRONTO: $winDest\book_review.exe" -ForegroundColor Green
Start-Process "$winDest\book_review.exe"
