$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.21/Voli.di.Carta_Setup_v1.3.21.exe'
$sha256 = '954df1b9856ab373990dacaa45112f55e792d499f040af23e03fb05163947777'
$notes = 'Anteprima libri in-app (WebView) e traduzioni complete in 10 lingue.'
$sql = "UPDATE app_version SET version = '1.3.21', download_url = '$downloadUrl', sha256_checksum = '$sha256', release_notes = '$notes' WHERE id = (SELECT MAX(id) FROM app_version)"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
