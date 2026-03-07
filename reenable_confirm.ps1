$body = '{"mailer_autoconfirm": false}'
try {
    Invoke-RestMethod `
        -Uri 'https://api.supabase.com/v1/projects/qyoupoyikbtizcqrswkt/config/auth' `
        -Method PATCH `
        -Headers @{ 'Authorization' = 'Bearer sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'; 'Content-Type' = 'application/json' } `
        -Body $body | Out-Null
    Write-Host "Conferma email riabilitata OK" -ForegroundColor Green
} catch {
    Write-Host $_.ErrorDetails.Message -ForegroundColor Red
}
