$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.23/Voli.di.Carta_Setup_v1.3.23.exe'
$sha256 = 'f8feda4ce3ae4096cea1e9405c110b2b979d8b3f8d0d6125587239c57657e188'
$notes = 'Ricerca libri migliorata: fino a 40 risultati, Google Books + Open Library in parallelo.'
$sql = "UPDATE app_version SET version = '1.3.23', download_url = '$downloadUrl', sha256_checksum = '$sha256', release_notes = '$notes' WHERE id = (SELECT MAX(id) FROM app_version)"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
