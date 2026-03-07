$json = Invoke-RestMethod 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json'
$latest = $json.releases | Where-Object { $_.channel -eq 'stable' } | Select-Object -First 1
$version = $latest.version
$archive = $latest.archive
$url = "https://storage.googleapis.com/flutter_infra_release/releases/$archive"
Write-Host "$version|$url"
