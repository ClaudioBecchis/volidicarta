$body = @{
    site_url       = "https://qyoupoyikbtizcqrswkt.supabase.co"
    uri_allow_list = "io.supabase.bookshelf://login-callback/,https://qyoupoyikbtizcqrswkt.supabase.co"
} | ConvertTo-Json

try {
    Invoke-RestMethod `
        -Uri 'https://api.supabase.com/v1/projects/qyoupoyikbtizcqrswkt/config/auth' `
        -Method PATCH `
        -Headers @{
            'Authorization' = 'Bearer sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
            'Content-Type'  = 'application/json'
        } `
        -Body $body | Out-Null
    Write-Host "Site URL aggiornato!" -ForegroundColor Green
} catch {
    Write-Host $_.ErrorDetails.Message -ForegroundColor Red
}
