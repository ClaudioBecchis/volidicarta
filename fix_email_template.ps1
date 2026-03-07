$template = @'
{
  "template": "<h2>Benvenuto in BookShelf!</h2><p>Clicca il link qui sotto per confermare il tuo account:</p><p><a href=\"{{ .ConfirmationURL }}\">Conferma il tuo account</a></p><p>Il link scade tra 24 ore.</p><p style=\"color:#888;font-size:12px\">BookShelf &middot; Claudio Becchis &middot; polariscore.it</p>",
  "subject": "Conferma il tuo account BookShelf"
}
'@

try {
    $r = Invoke-RestMethod `
        -Uri 'https://api.supabase.com/v1/projects/qyoupoyikbtizcqrswkt/config/auth/templates/confirmation' `
        -Method PATCH `
        -Headers @{
            'Authorization' = 'Bearer sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
            'Content-Type'  = 'application/json'
        } `
        -Body $template
    Write-Host "Template email aggiornato!" -ForegroundColor Green
} catch {
    Write-Host $_.ErrorDetails.Message -ForegroundColor Red
}
