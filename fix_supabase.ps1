$sql = @"
CREATE OR REPLACE FUNCTION update_likes_count()
RETURNS trigger AS `$func`$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public_reviews SET likes_count = likes_count + 1 WHERE id = NEW.review_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public_reviews SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.review_id;
  END IF;
  RETURN NULL;
END;
`$func`$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';
"@

$body = @{ query = $sql } | ConvertTo-Json -Depth 5

try {
    $r = Invoke-RestMethod `
        -Uri 'https://api.supabase.com/v1/projects/qyoupoyikbtizcqrswkt/database/query' `
        -Method POST `
        -Headers @{
            'Authorization' = 'Bearer sbp_1a1d43f3c0c4f7fd6b767d2080a086adea62f16a'
            'Content-Type'  = 'application/json'
        } `
        -Body $body
    Write-Host "OK!" -ForegroundColor Green
    $r
} catch {
    Write-Host "Errore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ErrorDetails.Message
}
