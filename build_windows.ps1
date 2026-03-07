$env:VSINSTALLDIR = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\'
Set-Location 'C:\Users\Black\BookReview\src'
& 'C:\Users\Black\flutter\bin\flutter.bat' build windows --release 2>&1 | Tee-Object -FilePath 'C:\Users\Black\BookReview\build_windows.log'
Write-Host "ExitCode: $LASTEXITCODE"
exit $LASTEXITCODE
