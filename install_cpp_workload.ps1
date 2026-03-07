$installer = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
$vsPath = "C:\Program Files\Microsoft Visual Studio\18\Community"

Write-Host "Installazione workload C++ per Visual Studio 2026..." -ForegroundColor Cyan

$args = @(
    "modify",
    "--installPath", $vsPath,
    "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.26100",
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",
    "--includeRecommended",
    "--quiet",
    "--norestart",
    "--wait"
)

$proc = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru -NoNewWindow
Write-Host "Exit code: $($proc.ExitCode)"

if ($proc.ExitCode -eq 0) {
    Write-Host "Workload C++ installato con successo!" -ForegroundColor Green
} else {
    Write-Host "Installazione completata con codice: $($proc.ExitCode)" -ForegroundColor Yellow
}
