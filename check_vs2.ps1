$vswhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

# Controlla se VS 2026 ha il componente VC
$result = & $vswhere -installationPath "C:\Program Files\Microsoft Visual Studio\18\Community" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json
Write-Host "VC Tools in VS2026: $($result -ne '[]' -and $result -ne '' -and $result -ne $null)"
Write-Host "Result: $result"

# Flutter usa vswhere per trovare VS - vediamo cosa trova esattamente
$latestWithVC = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json
Write-Host ""
Write-Host "Latest VS con VC Tools: $latestWithVC"

# Aggiungi VC tools al VS 2026
Write-Host ""
Write-Host "Provo ad installare VC Tools in VS 2026..." -ForegroundColor Yellow
$installer = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
$proc = Start-Process $installer -ArgumentList "modify --installPath `"C:\Program Files\Microsoft Visual Studio\18\Community`" --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CMake.Project --quiet --norestart --force" -Wait -PassThru
Write-Host "Exit: $($proc.ExitCode)"
