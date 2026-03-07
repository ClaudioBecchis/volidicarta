$sql = @"
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS `$func`$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
`$func`$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
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
    Write-Host "Trigger creato!" -ForegroundColor Green
} catch {
    Write-Host "Errore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ErrorDetails.Message
}
