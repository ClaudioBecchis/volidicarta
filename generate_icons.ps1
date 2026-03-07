$env:VSINSTALLDIR = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\'
Set-Location 'C:\Users\Black\BookReview\src'
& 'C:\Users\Black\flutter\bin\flutter.bat' pub get 2>&1
& 'C:\Users\Black\flutter\bin\flutter.bat' pub run flutter_launcher_icons 2>&1
Write-Host "ExitCode: $LASTEXITCODE"
