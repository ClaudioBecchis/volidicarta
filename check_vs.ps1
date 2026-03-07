$logPath = "$env:TEMP\dd_*"
$vsLog = Get-ChildItem "$env:TEMP" -Filter "dd_*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3
if ($vsLog) {
    foreach ($l in $vsLog) {
        Write-Host "Log: $($l.FullName)" -ForegroundColor Yellow
        Get-Content $l.FullName -Tail 10
    }
} else {
    Write-Host "Nessun log VS trovato"
}

# Controlla se cl.exe esiste
$cl = Get-ChildItem "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC" -Recurse -Filter "cl.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($cl) {
    Write-Host "cl.exe trovato: $($cl.FullName)" -ForegroundColor Green
} else {
    Write-Host "cl.exe NON trovato - MSVC non installato" -ForegroundColor Red
}

# Mostra contenuto VC\Tools
$tools = "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools"
if (Test-Path $tools) {
    Get-ChildItem $tools | Select-Object Name
} else {
    Write-Host "VC\Tools non esiste ancora"
}
