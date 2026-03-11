$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.19/Voli.di.Carta_Setup_v1.3.19.exe'
$sha256 = '3cb549d95d6239b25db916bcd925a23013256e808a4d71d96afe78ad2f7520aa'
$notes = 'Bugfix: permessi admin, backup cloud recensioni, statistiche per anno, privacy policy, wishlist genere, aggiornamento con dialog versione.'
$sql = "UPDATE app_version SET version = '1.3.19', download_url = '$downloadUrl', sha256_checksum = '$sha256', release_notes = '$notes' WHERE id = (SELECT MAX(id) FROM app_version)"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
