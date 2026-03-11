$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.20/Voli.di.Carta_Setup_v1.3.20.exe'
$sha256 = 'e6541b9fae69b15beeb8b8e001fe5ef6dd99513de58c0d902acccc05c7b4f7e8'
$notes = 'Dashboard visitatori admin: utenti online, iscrizioni per giorno, breakdown piattaforme.'
$sql = "UPDATE app_version SET version = '1.3.20', download_url = '$downloadUrl', sha256_checksum = '$sha256', release_notes = '$notes' WHERE id = (SELECT MAX(id) FROM app_version)"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
