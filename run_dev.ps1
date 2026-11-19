# Starts Beach Time in Chrome with hot reload (press r = hot reload, R = restart, q = quit).
# Runs from C:\Users\annit\beach_time (a link to this folder) because the Flutter
# web debug compiler breaks on the space in "BEACH TIME".
$flutter = Join-Path $env:USERPROFILE 'flutter\bin\flutter.bat'
$link = Join-Path $env:USERPROFILE 'beach_time'
if (-not (Test-Path $link)) {
  New-Item -ItemType Junction -Path $link -Target $PSScriptRoot | Out-Null
}
Set-Location $link
& $flutter pub get
& $flutter run -d chrome
