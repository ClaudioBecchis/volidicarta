$dest = "$env:TEMP\innosetup.exe"
Write-Host "Download InnoSetup..." -ForegroundColor Cyan
Invoke-WebRequest -Uri 'https://jrsoftware.org/download.php/is.exe' -OutFile $dest -UseBasicParsing
Write-Host "Installazione silenziosa..." -ForegroundColor Cyan
Start-Process -FilePath $dest -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait
Write-Host "InnoSetup installato!" -ForegroundColor Green
