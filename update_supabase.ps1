$token = 'sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
$projectRef = 'qyoupoyikbtizcqrswkt'
$downloadUrl = 'https://github.com/ClaudioBecchis/volidicarta/releases/download/v1.3.22/Voli.di.Carta_Setup_v1.3.22.exe'
$sha256 = '4c9b9954a364ff847405a3d8d32102b7b8b00d69c07a67d6fc4aa389fd3b9c32'
$notes = 'Pulsante PDF per libri di dominio pubblico. Anteprima in-app migliorata.'
$sql = "UPDATE app_version SET version = '1.3.22', download_url = '$downloadUrl', sha256_checksum = '$sha256', release_notes = '$notes' WHERE id = (SELECT MAX(id) FROM app_version)"
$body = @{ query = $sql } | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.supabase.com/v1/projects/$projectRef/database/query" -Method POST -Headers @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' } -Body $body
Write-Host "OK"
