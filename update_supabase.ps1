$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.38/Voli.di.Carta_v1.3.38.apk'
$sha256 = ''
$notes = 'Fix auto-update install + 33 fix layout/overflow/dark-mode.'
$sql = "INSERT INTO app_version (version, download_url, sha256_checksum, release_notes) VALUES ('1.3.38', '$downloadUrl', '$sha256', '$notes')"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
