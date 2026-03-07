reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowAllTrustedApps /t REG_DWORD /d 1 /f
Write-Host "Developer Mode abilitato con successo!" -ForegroundColor Green
Start-Sleep 2
