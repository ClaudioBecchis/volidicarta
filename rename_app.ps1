$files = Get-ChildItem -Path 'C:\Users\Black\BookReview\src\lib' -Recurse -Filter '*.dart' |
    Where-Object { $_.Name -ne 'supabase_config.dart' -and $_.Name -ne 'supabase_config.example.dart' }

foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw
    if ($content -match 'BookShelf|Bookshelf') {
        $content = $content -replace 'BookShelf Community', 'Voli di Carta Community'
        $content = $content -replace 'BookShelf', 'Voli di Carta'
        $content = $content -replace 'Bookshelf', 'Voli di Carta'
        Set-Content $f.FullName $content -NoNewline
        Write-Host "Updated: $($f.Name)"
    }
}

# Android manifest
$manifest = 'C:\Users\Black\BookReview\src\android\app\src\main\AndroidManifest.xml'
$c = Get-Content $manifest -Raw
$c = $c -replace 'android:label="BookShelf"', 'android:label="Voli di Carta"'
$c = $c -replace 'android:label="book_review"', 'android:label="Voli di Carta"'
Set-Content $manifest $c -NoNewline
Write-Host "Updated: AndroidManifest.xml"

# Windows CMakeLists
$cmake = 'C:\Users\Black\BookReview\src\windows\runner\CMakeLists.txt'
if (Test-Path $cmake) {
    $c = Get-Content $cmake -Raw
    $c = $c -replace '"book_review"', '"Voli di Carta"'
    $c = $c -replace '"BookShelf"', '"Voli di Carta"'
    Set-Content $cmake $c -NoNewline
    Write-Host "Updated: windows CMakeLists.txt"
}

# InnoSetup
$iss = 'C:\Users\Black\BookReview\bookshelf_setup.iss'
$c = Get-Content $iss -Raw
$c = $c -replace '#define MyAppName "BookShelf"', '#define MyAppName "Voli di Carta"'
$c = $c -replace 'BookShelf', 'Voli di Carta'
Set-Content $iss $c -NoNewline
Write-Host "Updated: bookshelf_setup.iss"

Write-Host "`nRinomina completata!" -ForegroundColor Green
