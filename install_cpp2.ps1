$installer = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
$vsPath = "C:\Program Files\Microsoft Visual Studio\18\Community"

Write-Host "Installazione componenti C++ per Flutter..." -ForegroundColor Cyan
Write-Host "Apparira' una finestra di avanzamento." -ForegroundColor Yellow

$argList = "modify " +
    "--installPath `"$vsPath`" " +
    "--add Microsoft.VisualStudio.Workload.NativeDesktop " +
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 " +
    "--add Microsoft.VisualStudio.Component.VC.CMake.Project " +
    "--add Microsoft.VisualStudio.Component.Windows10SDK.26100 " +
    "--includeRecommended " +
    "--passive " +
    "--norestart"

Write-Host "Comando: $installer $argList" -ForegroundColor Gray
$proc = Start-Process -FilePath $installer -ArgumentList $argList -Wait -PassThru
Write-Host "Exit code: $($proc.ExitCode)" -ForegroundColor Cyan
