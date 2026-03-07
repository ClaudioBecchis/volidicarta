$body = '{"uri_allow_list": "io.supabase.bookshelf://login-callback/"}'

try {
    $r = Invoke-RestMethod `
        -Uri 'https://api.supabase.com/v1/projects/qyoupoyikbtizcqrswkt/config/auth' `
        -Method PATCH `
        -Headers @{
            'Authorization' = 'Bearer sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
            'Content-Type'  = 'application/json'
        } `
        -Body $body
    Write-Host "OK! Redirect URL configurato." -ForegroundColor Green
} catch {
    Write-Host "Errore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ErrorDetails.Message
}
