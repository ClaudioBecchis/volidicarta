$url = "https://aka.ms/vs/17/release/vs_buildtools.exe"
$installer = "$env:TEMP\vs_buildtools.exe"

Write-Host "Download Visual Studio Build Tools 2022..." -ForegroundColor Cyan
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $installer -DisplayName "VS Build Tools 2022"

Write-Host "Installazione Build Tools 2022 con workload C++..." -ForegroundColor Cyan
Write-Host "Apparira' una finestra di avanzamento." -ForegroundColor Yellow

$args = @(
    "--add", "Microsoft.VisualStudio.Workload.VCTools",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add", "Microsoft.VisualStudio.Component.Windows10SDK.26100",
    "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",
    "--includeRecommended",
    "--passive",
    "--norestart",
    "--wait"
)

$proc = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
Write-Host "Exit code: $($proc.ExitCode)"

if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
    Write-Host "Build Tools 2022 installati!" -ForegroundColor Green
    # Trova cl.exe
    $cl = Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC" -Recurse -Filter "cl.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cl) { Write-Host "MSVC: $($cl.FullName)" -ForegroundColor Green }
} else {
    Write-Host "Attenzione, exit code: $($proc.ExitCode)" -ForegroundColor Yellow
}
