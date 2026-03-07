New-Item -ItemType Directory -Path 'C:\Users\Black\BookReview\keystore' -Force | Out-Null
$keytool = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot\bin\keytool.exe'
& $keytool -genkey -v `
    -keystore 'C:\Users\Black\BookReview\keystore\bookshelf-release.jks' `
    -alias bookshelf `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -storepass 'BookShelf2025!' `
    -keypass 'BookShelf2025!' `
    -dname 'CN=Claudio Becchis, OU=PolarisCore, O=PolarisCore, L=Italy, S=Italy, C=IT'
Write-Host "Keystore creato!" -ForegroundColor Green
